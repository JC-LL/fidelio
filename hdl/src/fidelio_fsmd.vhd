library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fidelio_lib;
use fidelio_lib.config_package.all;

entity fidelio_fsmd is
  port(
    reset_n : in  std_logic;
    clk     : in  std_logic;
    go      : in  std_logic;
    done    : out std_logic;
    inputs  : in  inputs_at;
    outputs : out outputs_at
  );
end entity;

architecture rtl of fidelio_fsmd is
  signal control : control_rt;
  signal status  : status_t;
begin

  controler : entity fidelio_lib.fidelio_fsm
    port map(
      reset_n => reset_n,
      clk     => clk,
      go      => go,
      status  => status,
      control => control,
      done    => done
    );

  datapath : entity fidelio_lib.fidelio_datapath
    port map(
      reset_n => reset_n,
      clk     => clk,
      status  => status,
      control => control,
      inputs  => inputs,
      outputs => outputs
    );

end rtl;
