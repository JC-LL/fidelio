--------------------------------------------------------------------------------
-- Generated automatically by Reggae compiler 
-- (c) Jean-Christophe Le Lann - 2011
-- date : Mon Jun  3 12:35:24 2019
--------------------------------------------------------------------------------
library ieee,std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity fidelio_soc is
  port(
    reset_n : in std_logic;
    clk     : in  std_logic;
    rx      : in  std_logic;
    tx      : out std_logic;
    leds    : out std_logic_vector(15 downto 0)
  );
end entity;
 
architecture rtl of fidelio_soc is
  -- bus
  signal ce      : std_logic;
  signal we      : std_logic;
  signal address : unsigned(7 downto 0);
  signal datain  : std_logic_vector(31 downto 0);
  signal dataout : std_logic_vector(31 downto 0);
  --
  signal sreset  : std_logic;
  -- debug
  signal slow_clk,slow_tick : std_logic;
 
begin
 
  -- ============== UART as Master of bus !=========
  uart_master : entity work.uart_bus_master
    generic map (DATA_WIDTH => 32)
    port map(
      reset_n => reset_n,
      clk     => clk,
      -- UART --
      rx      => rx,
      tx      => tx,
      -- Bus --
      ce      => ce,
      we      => we,
      address => address,
      datain  => datain,
      dataout => dataout
      );
   
  -- ==================fidelio_ip==================
  inst_fidelio_ip : entity work.fidelio_ip
    port map (
      reset_n => reset_n,
      clk     => clk,
      sreset  => sreset,
      ce      => ce,
      we      => we,
      address => address,
      datain  => datain,
      dataout => dataout
    );
   
  -- =================== DEBUG ====================
  ticker : entity work.slow_ticker(rtl)
    port map(
      reset_n   => reset_n,
      fast_clk  => clk,
      slow_clk  => slow_clk,
      slow_tick => slow_tick
      );
  leds <= "000000000000000" & slow_clk;
 
end;
