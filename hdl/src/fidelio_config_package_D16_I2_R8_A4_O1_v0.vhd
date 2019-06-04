library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package config_package is

  --_/_/_/_/ PARAMETERS for CONFIGURATION _/_/_/_/
  constant NB_INPUTS          : natural :=  2;
  constant NB_OUTPUTS         : natural :=  2;
  constant NB_REGS            : natural :=  4;
  constant DATA_WIDTH         : natural := 32;
  constant NB_ALUS            : natural :=  2;
  constant NB_STATUS_BITS     : natural :=  2;
  constant NB_STATES          : natural :=  7;
  constant NB_SCRATCHPAD_MEM  : natural :=  2;
  --
  constant NB_BITS_PROGRAM_ADDR : natural := integer(ceil(log2(real(NB_STATES))));

  type inputs_at is array(0 to NB_INPUTS-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  type outputs_at is array(0 to NB_OUTPUTS-1) of std_logic_vector(DATA_WIDTH-1 downto 0);

  type regs_t is array(0 to NB_REGS-1) of std_logic_vector(DATA_WIDTH-1 downto 0);

  type alus_datatype is array(0 to NB_ALUS-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  type alu_op_t is (
    NOP,
    OP_ADD,
    OP_SUB,
    OP_MUL,
    OP_DIV,
    OP_MOD,
    OP_SHL,
    OP_SHR,
    OP_OR,
    OP_AND,
    OP_XOR,
    OP_NOT,
    OP_EQ,
    OP_NEQ,
    OP_GT,
    OP_GTE);

  type alus_op_t is array(0 to NB_ALUS-1) of alu_op_t;

  type alu_control is record
    op           : alu_op_t;
    a_fed_by_reg : std_logic_vector(NB_REGS-1 downto 0);
    b_fed_by_reg : std_logic_vector(NB_REGS-1 downto 0);
    write_to_reg : std_logic_vector(NB_REGS-1 downto 0);
  end record;

  constant DEFAULT_ALU_CONTROL_T : alu_control :=(
    op => NOP,
    a_fed_by_reg => (others=>'0'),
    b_fed_by_reg => (others=>'0'),
    write_to_reg => (others=>'0')
  );

  type alus_control_t is array(0 to NB_REGS-1) of alu_control;

  constant DEFAULT_ALUS_CONTROL_T : alus_control_t :=(
    others => DEFAULT_ALU_CONTROL_T
  );

  type reg_control_t is record
    sreset : std_logic;
    enable : std_logic;
    feedback : std_logic;
  end record;

  constant DEFAULT_REG_CONTROL_T : reg_control_t := ('0','0','0');

  type regs_control_t is array(0 to NB_REGS-1) of reg_control_t;

  constant DEFAULT_REGS_CONTROL_T : regs_control_t := (others=> DEFAULT_REG_CONTROL_T);

  type control_rt is record
    alu    : alus_control_t;
    reg    : regs_control_t;
  end record;

  constant DEFAULT_CONTROL_RT : control_rt :=(
      alu => DEFAULT_ALUS_CONTROL_T,
      reg => DEFAULT_REGS_CONTROL_T
  );

  subtype status_t is std_logic_vector(NB_STATUS_BITS-1 downto 0);

  -- CONFIG
  type input_source_rt is record
    to_reg : std_logic_vector(NB_REGS-1 downto 0);
  end record;

  type inputs_sources_at is array(0 to NB_INPUTS-1) of input_source_rt;

  type alu_cfg_rt is record
    op_nop : std_logic;
    op_add : std_logic;
    op_sub : std_logic;
    op_mul : std_logic;
    op_div : std_logic;
    op_mod : std_logic;
    op_or  : std_logic;
    op_and : std_logic;
    op_xor : std_logic;
    op_not : std_logic;
    op_eq  : std_logic;
    op_neq : std_logic;
    op_gt  : std_logic;
    op_gte : std_logic;
  end record;

  type alus_cfg_at is array(0 to NB_ALUS-1) of alu_cfg_rt;

  type output_cfg_rt is record
    from_reg : std_logic_vector(NB_REGS-1 downto 0);
  end record;

  type outputs_source_at is array(0 to NB_OUTPUTS-1) of output_cfg_rt;
  --
  type status_cfg_rt is record
    reg : natural range 0 to NB_REGS-1;
    --alu  : natural range 0 to NB_ALUS-1;
    pos : natural range 0 to DATA_WIDTH-1;
  end record;

  type status_bits_at is array(0 to NB_STATUS_BITS-1) of status_cfg_rt;

  type spm_config_t is record
    nb_bits_addr : natural;
    control_reg  : natural;
    address_reg  : natural;
    input_reg    : natural;
    output_reg   : natural range 0 to NB_REGS-1;
  end record;

  type spms_config_t is array(0 to NB_SCRATCHPAD_MEM-1) of spm_config_t;

  type spm_control_t is record
    sreset  : std_logic;
    en      : std_logic;
    we      : std_logic;
    address : std_logic_vector(DATA_WIDTH-1 downto 0);--Warn. Depends on the final configuration
    datain  : std_logic_vector(DATA_WIDTH-1 downto 0);
  end record;

  type spm_result_t is record
    dataout  : std_logic_vector(DATA_WIDTH-1 downto 0);
  end record;

  type spms_control_t is array(0 to NB_SCRATCHPAD_MEM-1) of spm_control_t;
  type spms_result_t  is array(0 to NB_SCRATCHPAD_MEM-1) of spm_result_t;

  ---
  type config_rt is record
    input       : inputs_sources_at;
    alu         : alus_cfg_at;
    output      : outputs_source_at;
    status_bits : status_bits_at;
    scratchpads : spms_config_t;
  end record;

  --======== controler stuff
  constant NB_OPS_DEFINED : natural := alu_op_t'pos(alu_op_t'right) + 1;--'length is illegal!
  constant NB_BITS_FOR_OP : natural := integer(ceil(log2(real(NB_OPS_DEFINED))));
  constant SINGLE_ALU_CONTROL_SIZE : natural := NB_BITS_FOR_OP + integer(ceil(log2(real(NB_REGS))))*3;

  constant NB_BITS_PROGRAM_WORD : natural := NB_STATUS_BITS + NB_BITS_PROGRAM_ADDR +
                                             1 +  -- done
                                             1 +  -- next default
                                             NB_ALUS*SINGLE_ALU_CONTROL_SIZE +
                                             NB_REGS*3;-- +1 for default @dest (0=>same state; 1=> state+1)


  subtype program_word is std_logic_vector(NB_BITS_PROGRAM_WORD-1 downto 0);
  subtype program_addr is std_logic_vector(NB_BITS_PROGRAM_ADDR-1 downto 0);

  constant POS_BIT_DONE : natural := NB_BITS_PROGRAM_WORD - (NB_STATUS_BITS + NB_BITS_PROGRAM_ADDR + 1);

  type program_word_rt is record
    status_mask  : std_logic_vector(NB_STATUS_BITS-1 downto 0);
    jump_address : natural range 0 to NB_STATES-1;
    jump_default : std_logic;
    control      : control_rt;
  end record;

  constant DEFAULT_PROGRAM_WORD_RT : program_word_rt :=
    (
      status_mask  => (others=>'0'),
      jump_address => 0,
      jump_default => '1',--current state
      control      => DEFAULT_CONTROL_RT
    );
  --======= conversion functions

  -- from RAM bits to Symbolic control word.
  function bits_to_symbolic_control(bits : program_word) return program_word_rt;


  --======== configuration examples =========
  constant CONFIG_D16_I2_O2_R8_A2_S2 : config_rt :=(
    input => (
      0 => (to_reg => "0001"),--I0=>R0
      1 => (to_reg => "0010") --I1=>R1
    ),
    output => (
      0 => (from_reg => "0100"),--O0 <= R2
      1 => (from_reg => "1000") --O1 <= R3
    ),
    status_bits => (
      0 =>  (reg => 0, pos => 0),
      1 =>  (reg => 1, pos => 0)
    ),
    alu => (
      --     NOP, ADD SUB MUL DIV MOD OR_ AND XOR NOT EQ_ NEQ GT_ GTE
      0 => ( '1','1','1','0','0','0','0','0','0','0','1','0','0','0' ),--NOP,ADD,SUB,EQ,GT,GTE
      1 => ( '1','0','0','1','0','0','0','0','0','0','0','0','1','0' )--NOP,ADD,SUB,MUL
    ),

    scratchpads => (
      0 =>  (nb_bits_addr => 8, control_reg => 0, address_reg => 1, input_reg => 2, output_reg => 3),
      1 =>  (nb_bits_addr => 9, control_reg => 4, address_reg => 5, input_reg => 6, output_reg => 7)
    )
  );

  constant CONFIG : config_rt := CONFIG_D16_I2_O2_R8_A2_S2;

end package;
