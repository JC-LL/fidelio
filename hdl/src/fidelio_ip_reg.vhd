--------------------------------------------------------------------------------
-- Generated automatically by Reggae compiler
-- (c) Jean-Christophe Le Lann - 2011
-- date : Mon Jun  3 12:35:24 2019
--------------------------------------------------------------------------------
library ieee,std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fidelio_ip_pkg.all;

entity fidelio_ip_reg is
  port(
    reset_n : in  std_logic;
    clk     : in  std_logic;
    sreset  : in  std_logic;
    ce        : in  std_logic;
    we        : in  std_logic;
    address   : in  unsigned(7 downto 0);
    datain    : in  std_logic_vector(31 downto 0);
    dataout   : out std_logic_vector(31 downto 0);
    registers : out registers_type;
    sampling  : in sampling_type);
end fidelio_ip_reg;

architecture RTL of fidelio_ip_reg is

  --interface
  signal regs : registers_type;

  --addresses are declared here to avoid VHDL93 error /locally static/
  constant ADDR_RAM_ADDRESS        : unsigned(7 downto 0) := "00000000";-- 0x00;
  constant ADDR_RAM_DATAIN_B7_B0   : unsigned(7 downto 0) := "00000001";-- 0x01;
  constant ADDR_RAM_DATAIN_B15_B8  : unsigned(7 downto 0) := "00000010";-- 0x02;
  constant ADDR_RAM_DATAOUT_B7_B0  : unsigned(7 downto 0) := "00000011";-- 0x03;
  constant ADDR_RAM_DATAOUT_B15_B8 : unsigned(7 downto 0) := "00000100";-- 0x04;
  constant ADDR_RAM_CONTROL        : unsigned(7 downto 0) := "00000101";-- 0x05;
  constant ADDR_FSM_CONTROL        : unsigned(7 downto 0) := "00000110";-- 0x06;
  constant ADDR_FSM_STATUS         : unsigned(7 downto 0) := "00000111";-- 0x07;

  --application signals
  signal ram_dataout_value : std_logic_vector(31 downto 0);

begin

  write_reg_p : process(reset_n,clk)
  begin
    if reset_n='0' then
      regs <= REGS_INIT;
    elsif rising_edge(clk) then
      if ce='1' then
        if we='1' then
          case address is
            when ADDR_RAM_ADDRESS =>
              regs.ram_address.value <= datain(7 downto 0);
            when ADDR_RAM_DATAIN_B7_B0 =>
              regs.ram_datain_b7_b0.value <= datain(31 downto 0);
            when ADDR_RAM_DATAIN_B15_B8 =>
              regs.ram_datain_b15_b8.value <= datain(31 downto 0);
            when ADDR_RAM_DATAOUT_b7_b0 =>
              regs.ram_dataout_b7_b0.value <= datain(31 downto 0);
            when ADDR_RAM_DATAOUT_b15_b8 =>
              regs.ram_dataout_b15_b8.value <= datain(31 downto 0);
            when ADDR_RAM_CONTROL =>
              regs.ram_control.we <= datain(0);
              regs.ram_control.en <= datain(1);
              regs.ram_control.sreset <= datain(2);
              regs.ram_control.mode <= datain(3);
            when ADDR_FSM_CONTROL =>
              regs.fsm_control.go <= datain(0);
            when ADDR_FSM_STATUS =>
              regs.fsm_status.completed <= datain(0);
            when others =>
              null;
          end case;
        end if;
      else --no bus preemption => sampling or toggle
      --sampling
        regs.ram_dataout_b7_b0.value  <= sampling.ram_dataout_b7_b0_value;
        regs.ram_dataout_b15_b8.value <= sampling.ram_dataout_b15_b8_value;
      --toggling
        regs.ram_control.we <= '0';
        regs.ram_control.en <= '0';
        regs.ram_control.sreset <= '0';
        regs.fsm_control.go <= '0';
      end if;
    end if;
  end process;

  read_reg_p: process(reset_n,clk)
  begin
    if reset_n='0' then
      dataout <= (others=>'0');
    elsif rising_edge(clk) then
      if ce='1' then
        if we='0' then
          dataout <= (others=>'0');
          case address is
            when ADDR_RAM_ADDRESS =>
              dataout(7 downto 0) <= regs.ram_address.value;
            when ADDR_RAM_DATAIN_B7_B0 =>
              dataout(31 downto 0) <= regs.ram_datain_B7_B0.value;
            when ADDR_RAM_DATAIN_B15_B8 =>
              dataout(31 downto 0) <= regs.ram_datain_B15_B8.value;
            when ADDR_RAM_DATAOUT_B7_B0 =>
              dataout(31 downto 0) <= regs.ram_dataout_B7_B0.value;
            when ADDR_RAM_DATAOUT_B15_B8 =>
              dataout(31 downto 0) <= regs.ram_dataout_B15_B8.value;
            when ADDR_RAM_CONTROL =>
              dataout(0) <= regs.ram_control.we;
              dataout(1) <= regs.ram_control.en;
              dataout(2) <= regs.ram_control.sreset;
              dataout(3) <= regs.ram_control.mode;
            when ADDR_FSM_CONTROL =>
              dataout(0) <= regs.fsm_control.go;
            when ADDR_FSM_STATUS =>
              dataout(0) <= regs.fsm_status.completed;
            when others=>
              dataout <= (others=>'0');
          end case;
        end if;
      end if;
    end if;
  end process;
  registers <= regs;

end RTL;
