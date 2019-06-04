library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fidelio_lib;
use fidelio_lib.config_package.all;

entity fidelio_nisc is
  port(
    reset_n     : in  std_logic;
    clk         : in  std_logic;
    -- --------- from bus -------
    external_ce      : in  std_logic;
    external_we      : in  std_logic;
    external_address : in  unsigned(7 downto 0);
    external_datain  : in  std_logic_vector(NB_BITS_PROGRAM_WORD-1 downto 0);
    external_dataout : out std_logic_vector(NB_BITS_PROGRAM_WORD-1 downto 0);
    -----------------------------
    go      : in  std_logic;
    done    : out std_logic;
    inputs  : in  inputs_at;
    outputs : out outputs_at
  );
end entity;

architecture rtl of fidelio_nisc is

  -- controler/datapath signals :
  signal control : control_rt;
  signal status  : status_t;

  -- FSM => RAM
  signal pfsm_to_bram_en      : std_logic;
  signal pfsm_to_bram_address : program_addr;

  -- RAM => FSM
  signal bram_to_pfsm_code  : program_word;
  --
  signal bram_en      : std_logic;
  signal bram_address : program_addr;
  signal bram_code    : program_word;

  -- ram signals :
  signal sreset  : std_logic;
  signal ram_en      : std_logic;
  signal ram_we      : std_logic;
  signal ram_address : std_logic_vector(NB_BITS_PROGRAM_ADDR-1 downto 0);
  signal ram_datain  : std_logic_vector(NB_BITS_PROGRAM_WORD-1 downto 0);
  signal ram_dataout : std_logic_vector(NB_BITS_PROGRAM_WORD-1 downto 0);

begin

  -- ------------- C O N T R O L E R ------------
  controler : entity fidelio_lib.fidelio_pfsm
    port map(
      reset_n       => reset_n,
      clk           => clk,
      go            => go,
      bram_en       => pfsm_to_bram_en,
      bram_address  => pfsm_to_bram_address,
      bram_code     => bram_to_pfsm_code,
      status        => status,
      control       => control,
      done          => done
    );

  code_ram : entity fidelio_lib.fidelio_bram_xilinx
    generic map (
      nbits_addr => NB_BITS_PROGRAM_ADDR,
      nbits_data => NB_BITS_PROGRAM_WORD
    )
   port map (
      clk     => clk,
      sreset  => sreset,
      en      => ram_en,
      we      => ram_we,
      address => ram_address,
      datain  => ram_datain,
      dataout => ram_dataout
    );

  -- multiplexed ram access.
  ram_en      <= external_ce or pfsm_to_bram_en;
  ram_we      <= external_we;
  ram_address <= std_logic_vector(external_address(2 downto 0)) when external_ce='1' else pfsm_to_bram_address;
  ram_datain  <= std_logic_vector(external_datain)  when external_ce='1' else (others=>'0');
  external_dataout <= ram_dataout;
  -- -------------- D A T A P A T H ---------------
  datapath : entity fidelio_lib.fidelio_datapath
    port map(
      reset_n => reset_n,
      clk     => clk,
      status  => status,
      control => control,
      inputs  => inputs,
      outputs => outputs
    );

    -- remark :
    -- SPM memories are embedded in the datapath
    -- and cannot be initialized from outside

end rtl;
