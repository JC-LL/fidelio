--------------------------------------------------------------------------------
-- Generated automatically by Reggae compiler
-- (c) Jean-Christophe Le Lann - 2011
-- date : Mon Jun  3 12:35:24 2019
--------------------------------------------------------------------------------
library ieee,std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fidelio_lib;
use fidelio_lib.fidelio_ip_pkg.all;
use fidelio_lib.config_package.all;

entity fidelio_ip is
  port(
    reset_n : in  std_logic;
    clk     : in  std_logic;
    sreset  : in  std_logic;
    -- BUS -------------------------------------
    bus_ce      : in  std_logic;
    bus_we      : in  std_logic;
    bus_address : in  unsigned(7 downto 0);
    bus_datain  : in  std_logic_vector(31 downto 0);
    bus_dataout : out std_logic_vector(31 downto 0);
    --------------------------------------------
    inputs  : in  inputs_at;
    outputs : out outputs_at
    );
end fidelio_ip;

architecture RTL of fidelio_ip is

  --interface
  signal regs      : registers_type;
  signal sampling  : sampling_type;
  --
  signal done : std_logic;
  signal ram_dataout   : std_logic_vector(NB_BITS_PROGRAM_WORD-1 downto 0);
  signal external_data : std_logic_vector(39 downto 0);
begin

  regif_inst : entity work.fidelio_ip_reg
    port map(
      reset_n   => reset_n,
      clk       => clk,
      sreset    => sreset,
      ce        => bus_ce,
      we        => bus_we,
      address   => bus_address,
      datain    => bus_datain,
      dataout   => bus_dataout,
      registers => regs,
      sampling  => sampling
    );

   nisc : entity fidelio_lib.fidelio_nisc
    port map (
      reset_n          => reset_n,
      clk              => clk,
      -- access to RAM --------
      external_ce      => regs.ram_control.en,
      external_we      => regs.ram_control.we,
      external_address => unsigned(regs.ram_address.value),
      external_datain  => external_data,
      external_dataout => ram_dataout,
      -------------------------
      go               => regs.fsm_control.go,
      done             => done,
      inputs           => inputs,
      outputs          => outputs
    );

  external_data <= regs.ram_datain_b15_b8.value(7 downto 0) & regs.ram_datain_b7_b0.value;

  sampling.ram_dataout_b7_b0_value              <= ram_dataout(31 downto 0);
  --sampling.ram_dataout_b15_b8_value(7 downto 0) <= ram_dataout(39 downto 32);
  sampling.fsm_status.completed <= done;
end RTL;
