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
  signal bram_en_c           : std_logic;
  signal bram_address_c      : program_addr;
  --
  signal jump_address_c      : program_addr;
  signal jump_cond_c         : std_logic_vector(NB_STATUS_BITS-1 downto 0);
  signal status_mask_c       : std_logic_vector(NB_STATUS_BITS-1 downto 0);
  signal default_jump_bit_d : std_logic;
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

  comb_logic_p : process(go,state_r,bram_code,status)
    variable state_v : state_rt;
    variable code_v  : program_word;
    variable control_v : program_word_rt;
    variable bram_en_v      : std_logic;
    variable bram_address_v : program_addr;
    constant STATUS_ZERO :  std_logic_vector(NB_STATUS_BITS-1 downto 0) := std_logic_vector(to_unsigned(0,NB_STATUS_BITS));
    variable jump_cond : std_logic_vector(NB_STATUS_BITS-1 downto 0);
    variable jump_address : program_addr;
    variable default_jump_bit : std_logic;
    constant DEFAULT_JUMP_NEXT : std_logic := '1';
    variable conditional_v : std_logic;
  begin
    -- WARNING CHECK default !
    state_v        := state_r;
    code_v         := bram_code;
    control_v      := DEFAULT_PROGRAM_WORD_RT;
    bram_en_v      := CFALSE;
    bram_address_v := std_logic_vector(to_unsigned(0,NB_BITS_PROGRAM_ADDR));
    jump_address   := std_logic_vector(to_unsigned(0,NB_BITS_PROGRAM_ADDR));
    conditional_v  := CFALSE;
    -- SUPPRESS for debug
    jump_cond_c    <= (others=>'0');
    default_jump_bit_d <= 'U';

    case state_v.activation_status is
      when IDLE =>
        if go='1' then
          state_v.activation_status := RUNNING;
          state_v.done := CFALSE;
          bram_en_v    := '1';
          bram_address_v := std_logic_vector(to_unsigned(0,NB_BITS_PROGRAM_ADDR));
        end if;
      when RUNNING =>
        control_v := bits_to_symbolic_control(code_v);
        if control_v.done='1' then
          state_v.activation_status := IDLE;
          state_v.done := CTRUE;
        else
          conditional_v := control_v.conditional;
          if conditional_v='1' then
            report "COND !";
            jump_cond := (control_v.status_mask and status) ;
            default_jump_bit := control_v.jump_default;
            if jump_cond /= STATUS_ZERO then
              state_v.address_state := to_unsigned(control_v.jump_address,NB_BITS_PROGRAM_ADDR);
            else
              if default_jump_bit=DEFAULT_JUMP_NEXT then
                state_v.address_state := state_v.address_state + 1;
              end if;
            end if;
          else
            report "unconditional jump";
            state_v.address_state := to_unsigned(control_v.jump_address,NB_BITS_PROGRAM_ADDR);
          end if;
          bram_en_v    := '1';
          bram_address_v := std_logic_vector(state_v.address_state);
        end if;
      when others =>
        null;
    end case;

    state_c        <= state_v;
    control_c      <= control_v;
    bram_en_c      <= bram_en_v;
    bram_address_c <= bram_address_v;
    jump_address_c <= jump_address;

    -- FOR DEBUG only / SUPPRESS FOR SYNTHESIS !!!!!
    jump_cond_c    <= jump_cond;
    status_mask_c  <= control_v.status_mask;
    default_jump_bit_d <= default_jump_bit;
  end process;

  bram_en      <= bram_en_c;
  bram_address <= bram_address_c;
  control      <= control_c.control;
end rtl;
