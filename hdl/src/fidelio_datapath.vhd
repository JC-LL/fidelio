library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fidelio_lib;
use fidelio_lib.config_package.all;

entity fidelio_datapath is
  port (
    reset_n       : in  std_logic;
    clk           : in  std_logic;
    control       : in  control_rt;
    status        : out status_t;
    inputs        : in  inputs_at;
    outputs       : out outputs_at
    );
end entity;

architecture arch_v0 of fidelio_datapath is

  signal regs_r,to_regs_c, regs_source_c :regs_t;
  signal prim_source_c : regs_t;

  signal alu_a    : alus_datatype;
  signal alu_b    : alus_datatype;
  signal alu_f    : alus_datatype;
  signal alu_op   : alus_op_t;
  signal spm_ctrl : spms_control_t;
  signal spm_result : spms_result_t;

begin

  configure_inputs_to_reg: process(inputs,regs_r,spm_result)
  begin
    for r in 0 to NB_REGS-1 loop
      prim_source_c(r) <= regs_r(r);--default;
      for i in 0 to NB_INPUTS-1 loop
        if CONFIG.input(i).to_reg(r)='1' then
          prim_source_c(r) <= inputs(i);
        else
          if HAS_SCRATCHPADS then
            for s in 0 to NB_SCRATCHPAD_MEMS-1 loop
              if CONFIG.scratchpads(s).output_reg=r then
                prim_source_c(r) <= spm_result(s).dataout;
              else
                prim_source_c(r) <= regs_r(r);
              end if;
            end loop;
          end if;
        end if;
      end loop;
    end loop;
  end process;

  write_reg_sel_logic :process(control,to_regs_c,prim_source_c)
  begin
    for i in 0 to NB_REGS-1 loop
      if control.reg(i).feedback='1' then
        regs_source_c(i) <= to_regs_c(i);
      else
        regs_source_c(i) <= prim_source_c(i);
      end if;
    end loop;
  end process;

  regs_p: process(reset_n,clk)
  begin
    if reset_n='0' then
      regs_r <= (others => (others=>'0'));
    elsif rising_edge(clk) then
      for i in 0 to NB_REGS-1 loop
        if control.reg(i).sreset='1' then
          regs_r(i) <= (others=>'0');
        elsif control.reg(i).enable='1' then
          regs_r(i) <= regs_source_c(i);
        end if;
      end loop;
    end if;
  end process;

  read_reg_sel_logic: process(control,regs_r)
  begin
    for i in 0 to NB_ALUS-1 loop
      alu_a(i) <= (others=>'0');--default
      alu_b(i) <= (others=>'0');--default
      alu_op(i) <= control.alu(i).op;
      loop_reg:for j in 0 to NB_REGS-1 loop
        if control.alu(i).a_fed_by_reg=to_unsigned(j,NB_BITS_PER_REG_ID) then
          alu_a(i) <= regs_r(j);
        end if;
        if control.alu(i).b_fed_by_reg=to_unsigned(j,NB_BITS_PER_REG_ID) then
          alu_b(i) <= regs_r(j);
        end if;
      end loop;
    end loop;
  end process;

  gen_loop: for i in 0 to NB_ALUS-1 generate
    ALU_i : entity fidelio_lib.fidelio_alu(arch_v0)
      generic map(id => i)
      port map(
        a  => alu_a(i),
        b  => alu_b(i),
        op => alu_op(i),
        f  => alu_f(i)
      );
  end generate;

  interconnect_results: process(control,regs_r,alu_f)
  begin
    for i in 0 to NB_REGS-1 loop
      to_regs_c(i) <= regs_r(i);--default
      if control.reg(i).feedback='1' then
        loop_alu:for j in 0 to NB_ALUS-1 loop
          if control.alu(j).write_to_reg=to_unsigned(i,NB_BITS_PER_REG_ID) then
            to_regs_c(i) <= alu_f(j);
            exit loop_alu;
          end if;
        end loop;
      end if;
    end loop;
  end process;

  output_wiring : process(regs_r)
  begin
    for o in 0 to NB_OUTPUTS-1 loop
      for i in 0 to NB_REGS-1 loop
        if CONFIG.output(o).from_reg(i)='1' then
          outputs(o) <= regs_r(i);
        end if;
      end loop;
    end loop;
  end process;

  status_wiring : process(regs_r)
    variable reg_id  : natural range 0 to NB_REGS-1;
    variable bit_pos : natural range 0 to DATA_WIDTH-1;
  begin
    for i in 0 to NB_STATUS_BITS-1 loop
      reg_id    := CONFIG.status_bits(i).reg;
      bit_pos   := CONFIG.status_bits(i).pos;
      status(i) <= regs_r(reg_id)(bit_pos);
    end loop;
  end process;

  --
  scratchpad_instanciations : for s in 0 to NB_SCRATCHPAD_MEMS-1 generate

    scratchpad_mem : entity fidelio_lib.fidelio_bram_xilinx
        generic map (
          nbits_addr => CONFIG.scratchpads(s).nb_bits_addr,
          nbits_data => DATA_WIDTH
        )
        port map(
          clk     => clk,
          sreset  => spm_ctrl(s).sreset,
          en      => spm_ctrl(s).en,
          we      => spm_ctrl(s).we,
          address => spm_ctrl(s).address(CONFIG.scratchpads(s).nb_bits_addr-1 downto 0),
          datain  => spm_ctrl(s).datain,
          dataout => spm_result(s).dataout
        );

    spm_ctrl(s).sreset <= regs_r(CONFIG.scratchpads(s).control_reg)(0);
    spm_ctrl(s).en     <= regs_r(CONFIG.scratchpads(s).control_reg)(1);
    spm_ctrl(s).we     <= regs_r(CONFIG.scratchpads(s).control_reg)(2);
    spm_ctrl(s).address<= regs_r(CONFIG.scratchpads(s).address_reg);
    spm_ctrl(s).datain <= regs_r(CONFIG.scratchpads(s).input_reg);
  end generate;

end arch_v0;
