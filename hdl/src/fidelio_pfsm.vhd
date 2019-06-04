library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fidelio_lib;
use fidelio_lib.config_package.all;

entity fidelio_pfsm is
  port(
    reset_n      : in  std_logic;
    clk          : in  std_logic;
    go           : in  std_logic;
    bram_en      : out std_logic;
    bram_address : out program_addr;
    bram_code    : in  program_word;
    status       : in  status_t;
    control      : out control_rt;
    done         : out std_logic
  );
end entity;

architecture rtl of fidelio_pfsm is

  type activation_status_et is (IDLE,RUNNING);

  signal activation_status : activation_status_et;

  type state_rt is record
    activation_status : activation_status_et;
    address_state     : unsigned(NB_BITS_PROGRAM_ADDR-1 downto 0);
    done              : std_logic;
  end record;

  constant CTRUE  : std_logic :='1';
  constant CFALSE : std_logic :='0';

  constant STATE_INIT : state_rt :=(
    activation_status => IDLE,
    address_state     => to_unsigned(0,NB_BITS_PROGRAM_ADDR),
    done              => CTRUE
  );

  signal state_r,state_c     : state_rt;
  signal control_r,control_c : program_word_rt;
begin

  reg_p: process(reset_n,clk)
  begin
    if reset_n='0' then
      state_r   <= STATE_INIT;
      control_r <= DEFAULT_PROGRAM_WORD_RT;
    elsif rising_edge(clk) then
      state_r   <= state_c;
      control_r <= control_c;
    end if;
  end process;

  comb_logic_p : process(go,state_r,bram_code)
    variable state_v : state_rt;
    variable code_v  : program_word;
    variable control_v : program_word_rt;
    variable bram_en_v      : std_logic;
    variable bram_address_v : program_addr;
  begin
    state_v   := state_r;
    code_v    := bram_code;
    control_v := DEFAULT_PROGRAM_WORD_RT;
    bram_en_v    := '0';
    bram_address_v := std_logic_vector(to_unsigned(0,NB_BITS_PROGRAM_ADDR));
    case state_v.activation_status is
      when IDLE =>
        if go='1' then
          state_v.activation_status := RUNNING;
          state_v.done := CFALSE;
          bram_en_v    := '1';
          bram_address_v := std_logic_vector(to_unsigned(0,NB_BITS_PROGRAM_ADDR));
        end if;
      when RUNNING =>
        if code_v(POS_BIT_DONE)='1' then
          state_v.activation_status := IDLE;
          state_v.done := CTRUE;
        else
          control_v := bits_to_symbolic_control(code_v);
          bram_en_v    := '1';
          bram_address_v := std_logic_vector(to_unsigned(0,NB_BITS_PROGRAM_ADDR));
        end if;
      when others =>
        null;
    end case;
    state_c <= state_v;
    control_c <= control_v;
  end process;

end rtl;
