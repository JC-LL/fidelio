--------------------------------------------------------------------------------
-- Generated automatically by Reggae compiler
-- (c) Jean-Christophe Le Lann - 2011
-- date : Mon Jun  3 12:35:24 2019
--------------------------------------------------------------------------------
library ieee,std;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package fidelio_ip_pkg is

  type ram_address_reg is record
    value : std_logic_vector(7 downto 0);
  end record;

  constant RAM_ADDRESS_INIT: ram_address_reg :=(
    value => "00000000");

  type ram_datain_b7_b0_reg is record
    value : std_logic_vector(31 downto 0);
  end record;

  type ram_datain_b15_b8_reg is record
    value : std_logic_vector(31 downto 0);
  end record;

  constant RAM_DATAIN_B7_B0_INIT: ram_datain_B7_B0_reg :=(
    value => "00000000000000000000000000000000");

  constant RAM_DATAIN_B15_B8_INIT: ram_datain_B15_B8_reg :=(
    value => "00000000000000000000000000000000");

  type ram_dataout_b7_b0_reg is record
    value : std_logic_vector(31 downto 0);
  end record;

  type ram_dataout_b15_b8_reg is record
    value : std_logic_vector(31 downto 0);
  end record;

  constant RAM_DATAOUT_b7_b0_INIT: ram_dataout_B7_B0_reg :=(
    value => "00000000000000000000000000000000");

  constant RAM_DATAOUT_b15_b8_INIT: ram_dataout_B15_B8_reg :=(
    value => "00000000000000000000000000000000");

  type ram_control_reg is record
    we     : std_logic;
    en     : std_logic;
    sreset : std_logic;
    mode   : std_logic;
  end record;

  constant RAM_CONTROL_INIT: ram_control_reg :=(
    we     => '0',
    en     => '0',
    sreset => '0',
    mode   => '0');

  type fsm_control_reg is record
    go : std_logic;
  end record;

  constant FSM_CONTROL_INIT: fsm_control_reg :=(
    go => '0');

  type fsm_status_reg is record
    completed : std_logic;
  end record;

  constant FSM_STATUS_INIT: fsm_status_reg :=(
    completed => '0');

  type registers_type is record
    ram_address        : ram_address_reg;       -- 0x0
    ram_datain_b7_b0   : ram_datain_B7_B0_reg;  -- 0x1
    ram_datain_b15_b8  : ram_datain_B15_B8_reg; -- 0x2
    ram_dataout_b7_b0  : ram_dataout_B7_B0_reg; -- 0x3
    ram_dataout_b15_b8 : ram_dataout_B15_B8_reg;-- 0x4
    ram_control        : ram_control_reg;       -- 0x5
    fsm_control        : fsm_control_reg;       -- 0x6
    fsm_status         : fsm_status_reg;        -- 0x7
  end record;

  constant REGS_INIT : registers_type :=(
    ram_address        => RAM_ADDRESS_INIT,
    ram_datain_b7_b0   => RAM_DATAIN_B7_B0_INIT,
    ram_datain_b15_b8  => RAM_DATAIN_B15_B8_INIT,
    ram_dataout_b7_b0  => RAM_DATAOUT_B7_B0_INIT,
    ram_dataout_b15_b8 => RAM_DATAOUT_B15_B8_INIT,
    ram_control => RAM_CONTROL_INIT,
    fsm_control => FSM_CONTROL_INIT,
    fsm_status  => FSM_STATUS_INIT);

  --sampling values from IPs
  type sampling_type is record
    ram_dataout_b7_b0_value  : std_logic_vector(31 downto 0);
    ram_dataout_b15_b8_value : std_logic_vector(31 downto 0);
    fsm_status : fsm_status_reg;
  end record;

end package;
