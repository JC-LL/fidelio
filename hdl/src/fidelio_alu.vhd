library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library fidelio_lib;
use fidelio_lib.config_package.all;

entity fidelio_alu is
  generic(id : natural:=0);
  port (
    a             : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    b             : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    op            : in  alu_op_t;
    f             : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity;

architecture arch_v0 of fidelio_alu is
  signal s_a,s_b : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal s_add : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal s_sub : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal s_mul : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal s_div : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal s_mod : std_logic_vector(DATA_WIDTH-1 downto 0);
  --
  signal s_shl : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal s_shr : std_logic_vector(DATA_WIDTH-1 downto 0);
  --
  signal s_or  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal s_and : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal s_xor : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal s_not : std_logic_vector(DATA_WIDTH-1 downto 0);
  --
  signal s_eq  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal s_neq : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal s_gt  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal s_gte : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal s_lt  : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal s_lte : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

  adder      : s_add <= std_logic_vector(signed(s_a)+signed(s_b));
  substractor: s_sub <= std_logic_vector(signed(s_a)-signed(s_b));
  multiplier : s_mul <= std_logic_vector(resize(signed(s_a)*signed(s_b),DATA_WIDTH));
  divider    : s_div <= (others=>'0');--std_logic_vector(signed(s_a)/signed(s_b));
  modulo     : s_mod <= (others=>'0');--std_logic_vector(signed(s_a) mod signed(s_b));
  -- shifter_l  : s_shl <= shl(unsigned(s_a),to_integer(unsigned(s_b)));
  -- shifter_r  : s_shr <= shl(unsigned(s_a),to_integer(unsigned(s_b)));
  logic_and  : s_or  <= s_a  or s_b;
  logic_or   : s_and <= s_a and s_b;
  logic_xor  : s_xor <= s_a xor s_b;
  logic_not  : s_not <= not(s_a);
  compare_eq : s_eq  <= std_logic_vector(to_signed(1,DATA_WIDTH)) when (signed(s_a) = signed(s_b))   else std_logic_vector(to_signed(0,DATA_WIDTH));
  compare_neq: s_neq <= std_logic_vector(to_signed(1,DATA_WIDTH)) when (signed(s_a) /= signed(s_b))  else std_logic_vector(to_signed(0,DATA_WIDTH));
  compare_gt : s_gt  <= std_logic_vector(to_signed(1,DATA_WIDTH)) when (signed(s_a)  >  signed(s_b)) else std_logic_vector(to_signed(0,DATA_WIDTH));
  compare_gte: s_gte <= std_logic_vector(to_signed(1,DATA_WIDTH)) when (signed(s_a)  >= signed(s_b)) else std_logic_vector(to_signed(0,DATA_WIDTH));


  config_and_compute : process(a,b)
    variable v_a : std_logic_vector(DATA_WIDTH-1 downto 0);
    variable v_b : std_logic_vector(DATA_WIDTH-1 downto 0);
  begin
      v_a:=(others=>'0');
      v_b:=(others=>'0');

      if config.alu(id).op_add='1' then
        v_a := a;
        v_b := b;
      end if;

      if config.alu(id).op_sub='1' then
        v_a := a;
        v_b := b;
      end if;

      if config.alu(id).op_mul='1' then
        v_a := a;
        v_b := b;
      end if;

      if config.alu(id).op_div='1' then
        v_a := a;
        v_b := b;
      end if;

      if config.alu(id).op_mod='1' then
        v_a := a;
        v_b := b;
      end if;

      if config.alu(id).op_eq='1' then
        v_a := a;
        v_b := b;
      end if;

      if config.alu(id).op_neq='1' then
        v_a := a;
        v_b := b;
      end if;

      if config.alu(id).op_gt='1' then
        v_a := a;
        v_b := b;
      end if;

      if config.alu(id).op_gte='1' then
        v_a := a;
        v_b := b;
      end if;

      --
      s_a <= v_a;
      s_b <= v_b;
  end process;

  compute: process(op,s_add,
                      s_sub,
                      s_mul,
                      s_div,
                      s_mod,
                      s_shl,
                      s_shr,
                      s_or,
                      s_and,
                      s_xor,
                      s_not,
                      s_eq,
                      s_neq,
                      s_gt,
                      s_gte)
  begin
    case op is
      when OP_ADD => f <= s_add;
      when OP_SUB => f <= s_sub;
      when OP_MUL => f <= s_mul;
      when OP_DIV => f <= s_div;
      when OP_MOD => f <= s_mod;
      when OP_SHL => f <= s_shl;
      when OP_SHR => f <= s_shr;
      when OP_OR  => f <= s_or;
      when OP_AND => f <= s_and;
      when OP_XOR => f <= s_xor;
      when OP_EQ  => f <= s_eq;
      when OP_NEQ => f <= s_neq;
      when OP_GT  => f <= s_gt;
      when OP_GTE => f <= s_gte;
      when others => f <= (others=>'0');
    end case;
  end process;

end arch_v0;
