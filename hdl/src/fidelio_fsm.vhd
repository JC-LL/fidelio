library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fidelio_lib;
use fidelio_lib.config_package.all;

entity fidelio_fsm is
  port(
    reset_n : in  std_logic;
    clk     : in  std_logic;
    go      : in  std_logic;
    status  : in  status_t;
    control : out control_rt;
    done    : out std_logic
  );
end entity;

architecture rtl of fidelio_fsm is

  type state_type is (IDLE,S1,S2,S3);

  type regs_t is record
    state : state_type;
    done  : std_logic;
  end record;

  signal go_r          : std_logic;
  signal regs_r,regs_c : regs_t;

begin

  state_p: process(reset_n,clk)
  begin
    if reset_n='0' then
      go_r   <= '0';
      regs_r <= (IDLE,'0');
    elsif rising_edge(clk) then
      regs_r <= regs_c;
      go_r   <= go;
    end if;
  end process;

  next_state : process(go_r,regs_r,status)
    variable r : regs_t;
  begin
    r := regs_r;
    case r.state is
      when IDLE =>
        if go_r='1' then
          r.state := S1;
        end if;
      when S1 =>
        r.state := S2;
      when S2 =>
        r.state := S3;
      when S3 =>
        r.state := IDLE;
        r.done := '1';
    when others=>
      null;
    end case;
    regs_c <= r;
  end process;

end rtl;
