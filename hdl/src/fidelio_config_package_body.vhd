library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library utils_lib;
use utils_lib.txt_util.all;

package body config_package is

  function bits_to_symbolic_control(bits : program_word) return program_word_rt is
    variable word      : program_word_rt;
    variable control   : control_rt;
    variable alus_ctrl : alus_control_t;
    variable regs_ctrl : regs_control_t;
    variable op_id     : natural ;
    variable msb,lsb   : natural;
  begin
    msb:=NB_BITS_PROGRAM_WORD-1;
    lsb:=msb;
    word.conditional := bits(lsb);
    report "cond?     " & str(msb) & ".." & str(lsb) & " : " & str(word.conditional);


    msb:=lsb-1;
    lsb:=msb-NB_STATUS_BITS+1;
    word.status_mask := bits(msb downto lsb);
    report "mask      " & str(msb) & ".." & str(lsb) & " : " & str(word.status_mask);

    msb:=lsb-1;
    lsb:=msb-NB_BITS_PROGRAM_ADDR+1;
    word.jump_address:= to_integer(unsigned(bits(msb downto lsb)));
    report "j@        " & str(msb) & ".." & str(lsb) & " : " & str(word.jump_address);


    msb:=lsb-1;
    lsb:=msb-1+1;
    word.done:=bits(lsb);
    report "done      " & str(msb) & ".." & str(lsb) & " : " & str(word.done);

    msb:=lsb-1;
    lsb:=msb-1+1;
    word.jump_default:=bits(lsb);
    report "jdef      " & str(msb) & ".." & str(lsb)& " : " & str(word.jump_default);

    for alu in 0 to NB_ALUS-1 loop
      msb:=lsb-1;
      lsb:=msb-NB_BITS_FOR_OP+1;
      report "op " & str(msb) & ".." & str(lsb);
      op_id := to_integer(unsigned(bits(msb downto lsb)));
      report "OP_ID(" & str(alu) & ")=" & str(op_id);
      alus_ctrl(alu).op :=alu_op_t'VAL(op_id);
      report "OP   (" & str(alu) & ")= " &  alu_op_t'image(alus_ctrl(alu).op);

      msb := lsb-1;
      lsb := msb-NB_BITS_PER_REG_ID+1;
      alus_ctrl(alu).a_fed_by_reg := unsigned(bits(msb downto lsb));
      report "a        " & str(msb) & ".." & str(lsb) & " : " & str(alus_ctrl(alu).a_fed_by_reg);


      msb:=lsb-1;
      lsb:=msb-NB_BITS_PER_REG_ID+1;
      alus_ctrl(alu).b_fed_by_reg:=unsigned(bits(msb downto lsb));
      report "b        " & str(msb) & ".." & str(lsb)& " : " & str(alus_ctrl(alu).b_fed_by_reg);


      msb:=lsb-1;
      lsb:=msb-NB_BITS_PER_REG_ID+1;
      alus_ctrl(alu).write_to_reg:=unsigned(bits(msb downto lsb));
      report "dest     " & str(msb) & ".." & str(lsb)& " : " & str(alus_ctrl(alu).write_to_reg);

    end loop;

    control.alu := alus_ctrl;

    for reg in 0 to NB_REGS-1 loop
      msb:=lsb-1;
      lsb:=msb-1+1;
      report "feedback " & str(msb) & ".." & str(lsb);
      regs_ctrl(reg).feedback := bits(lsb);
      msb:=lsb-1;
      lsb:=msb-1+1;
      report "enable   " & str(msb) & ".." & str(lsb);
      regs_ctrl(reg).enable   := bits(lsb);
      msb:=lsb-1;
      lsb:=msb-1+1;
      report "sreset   " & str(msb) & ".." & str(lsb);
      regs_ctrl(reg).sreset   := bits(lsb);
    end loop;

    control.reg := regs_ctrl;
    word.control := control;
    return word;
  end;

  procedure print(word : program_word_rt) is
  begin
    report "mask " & str(word.status_mask);
  end procedure;

end package body;
