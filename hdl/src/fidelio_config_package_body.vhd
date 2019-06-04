library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package body config_package is

  function bits_to_symbolic_control(bits : program_word) return program_word_rt is
    variable word : program_word_rt;
    variable alus_ctrl : alus_control_t;
    variable op_id : natural ;
    variable pos : natural;
  begin
    pos:=NB_BITS_PROGRAM_WORD-1;
    word.status_mask := bits(pos downto pos-NB_STATUS_BITS);
    pos:=pos-NB_STATUS_BITS-1;
    word.jump_address:= to_integer(unsigned(bits(pos downto pos-NB_BITS_PROGRAM_ADDR)));
    pos:=pos-NB_BITS_PROGRAM_ADDR-1;
    word.jump_default:=bits(pos);
    pos:=pos-1;
    for alu in 0 to NB_ALUS-1 loop
      op_id := to_integer(unsigned(bits(pos downto pos-NB_BITS_FOR_OP)));
      alus_ctrl(alu).op :=alu_op_t'VAL(op_id);
      pos:=pos-1;
      alus_ctrl(alu).a_fed_by_reg:=bits(pos downto pos-NB_REGS);
      pos:=pos-1;
      alus_ctrl(alu).b_fed_by_reg:=bits(pos downto pos-NB_REGS);
      pos:=pos-1;
      alus_ctrl(alu).write_to_reg:=bits(pos downto pos-NB_REGS);
      pos:=pos-1;
    end loop;
    return word;
  end;

end package body;
