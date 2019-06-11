-----------------------------------------------------------------
-- This file was generated automatically by vhdl_tb Ruby utility
-- date : (d/m/y) 03/06/2019 11:50
-- Author : Jean-Christophe Le Lann - 2014
-----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;--hread

library std;
use std.textio.all;

library utils_lib;
use utils_lib.txt_util.all;

library fidelio_lib;
use fidelio_lib.config_package.all;

entity fidelio_ip_tb is
end entity;

architecture bhv of fidelio_ip_tb is

  constant HALF_PERIOD : time := 5 ns;

  signal clk     : std_logic := '0';
  signal reset_n : std_logic := '0';
  signal sreset  : std_logic := '0';
  signal running : boolean   := true;

  procedure wait_cycles(n : natural) is
   begin
     for i in 1 to n loop
       wait until rising_edge(clk);
     end loop;
   end procedure;


   type bfm is record
     ce   : std_logic;
     we   : std_logic;
     addr : unsigned( 7 downto 0);
     din  : std_logic_vector(DATA_WIDTH - 1 downto 0);
   end record;

  constant BFM_DEFAULT : bfm := (
    ce   => '0',
    we   => '0',
    addr => to_unsigned(0,8),
    din  => (others=>'0')
  );

  signal bus_s : bfm := BFM_DEFAULT;

  signal bus_s_dout : std_logic_vector(DATA_WIDTH - 1 downto 0);

  signal go          : std_logic;
  signal done        : std_logic;

  constant STIMULI : inputs_at :=(
    0 => std_logic_vector(to_unsigned(42,DATA_WIDTH)),
    1 => std_logic_vector(to_unsigned(24,DATA_WIDTH))
  );

  signal inputs      : inputs_at := STIMULI;
  signal outputs     : outputs_at;

begin
  -------------------------------------------------------------------
  -- clock and reset
  -------------------------------------------------------------------
  reset_n <= '0','1' after 666 ns;

  clk <= not(clk) after HALF_PERIOD when running else clk;

  --------------------------------------------------------------------
  -- Design Under Test
  --------------------------------------------------------------------
  dut : entity work.fidelio_ip(rtl)
        port map (
          reset_n     => reset_n    ,
          clk         => clk        ,
          sreset      => sreset     ,
          ---------------------------
          bus_ce      => bus_s.ce   ,
          bus_we      => bus_s.we   ,
          bus_address => bus_s.addr ,
          bus_datain  => bus_s.din  ,
          bus_dataout => bus_s_dout ,
          ---------------------------
          inputs      => inputs     ,
          outputs     => outputs
        );

  --------------------------------------------------------------------
  -- sequential stimuli
  --------------------------------------------------------------------
  stim : process

    procedure print_config is
    begin
      report "------------- CONFIG ---------------";
      report "mask                              = " & str(NB_STATUS_BITS);
      report "addr                              = " & str(NB_BITS_PROGRAM_ADDR);
      report "done                              = " & str(1);
      report "default jump                      = " & str(1);
      report "NB_ALUS * SINGLE_ALU_CONTROL_SIZE = " & str(NB_ALUS * SINGLE_ALU_CONTROL_SIZE);
      report " - NB_ALUS                        = " & str(NB_ALUS);
      report " - SINGLE_ALU_CONTROL_SIZE        = " & str(SINGLE_ALU_CONTROL_SIZE);
      report "NB_REGS*3                         = " & str(NB_REGS*3);
      report " - NB_REGS                        = " & str(NB_REGS);
      report " - NB_BITS_PER_REG_ID             = " & str(NB_BITS_PER_REG_ID);
      report "------------------------------------";
      report "NB_BITS_PROGRAM_WORD = " & str(NB_BITS_PROGRAM_WORD);
      report "------------------------------------";
    end procedure;

    procedure bfm_write(
      address : unsigned(7 downto 0);
      data    : std_logic_vector(31 downto 0)
    ) is
    begin
      wait until rising_edge(clk);
      bus_s.ce  <= '1';
      bus_s.we  <= '1';
      bus_s.addr <= address;
      bus_s.din  <= data;
      wait until rising_edge(clk);
      bus_s.ce  <= '0';
      bus_s.we  <= '0';
    end procedure;

    procedure bfm_read(
      address : unsigned(7 downto 0)
    ) is
    begin
      wait until rising_edge(clk);
      bus_s.ce   <= '1';
      bus_s.we   <= '0';
      bus_s.addr <= address;
      bus_s.din  <= (others=>'0');
      wait until rising_edge(clk);
      bus_s.ce   <= '0';
      bus_s.we   <= '0';
      bus_s.din  <= (others=>'0');
    end procedure;

    procedure download(filename : string) is
      file f          : text;
      variable L      : line;
      variable status : file_open_status;
      variable addr   : std_logic_vector(31 downto 0);
      variable value  : std_logic_vector(39 downto 0);
      variable str17  : string(1 to 17);
      variable char   : character;
    begin
      FILE_OPEN(status, F, filename, read_mode);
      if status /= open_ok then
        report "problem to open stimulus file " & filename severity error;
      else
        report "downloading data from file '" & filename & "'";
        while not(ENDFILE(f)) loop
          readline(f,l);
          hread(l,addr);
          read(l,char);--space
          hread(l,value);
          report hstr(addr) & " " & hstr(value);
          -- write in reg 0x0 : address of RAM
          bfm_write(x"00",addr);
          -- write in reg 0x1 : datain of RAM
          bfm_write(x"01",value(31 downto 0));
          -- write in reg 0x2 : datain of RAM
          bfm_write(x"02",x"000000" & value(39 downto 32));
          -- write in reg 0x3 : control of RAM
          bfm_write(x"05",x"00000003");-- 0...011" (ce,we)
        end loop;
        --bfm_write(x"03",x"00000008");-- 0...1000" (mode=1)
        report "end of download. Good.";
      end if;
    end procedure;

    procedure start_nisc is
    begin
      report "starting NISC";
      bfm_write(x"06",x"00000001");
    end procedure;

    procedure wait_nisc_done is
      variable count : natural;
      variable done : boolean :=false;
    begin
      report "waiting for NISC completion";
      while done=false loop
        count:=count+1;
        bfm_read(x"06");
        done := bus_s_dout(0)='1';
        if (count mod 10=0) then
          report "#read status : " & str(count);
        end if;
        if count > 20 then
          report "aborting !" severity failure;
        end if;
      end loop;
    end procedure;

   begin
     report "running testbench for fidelio_nisc(rtl)";
     print_config;
     report "waiting for asynchronous reset";
     wait until reset_n='1';
     wait_cycles(100);
     report "applying stimuli...";
     download("program.hex");

     wait_cycles(20);
     start_nisc;
     wait_nisc_done;
     report "end of simulation";
     running <=false;
     wait;
   end process;

end bhv;
