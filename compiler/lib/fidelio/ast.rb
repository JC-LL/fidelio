module Fidelio

  class Ast
  end

  class Program < Ast
    attr_accessor :name,:config,:controler
  end

  class Config < Ast
    attr_accessor :inputs,:outputs,:regs,:data_width,:states
    attr_accessor :status_bits
    attr_accessor :alus
  end

  class Input < Ast
    attr_accessor :id,:to_reg
  end

  class Output < Ast
    attr_accessor :id,:from_reg
  end

  class StatusBit < Ast
    attr_accessor :id,:reg,:pos
  end

  class AluConfig < Ast
    attr_accessor :id,:ops,:src_a,:src_b,:dest
  end

  class Controler < Ast
    attr_accessor :states
    def initialize
      @states=[]
    end
  end

  class State < Ast
    attr_accessor :id,:spec,:jump,:control,:done
  end

  class Jump < Ast
    attr_accessor :next,:status_mask,:default
  end

  class Control < Ast
    attr_accessor :alus,:regs
    def initialize
      @alus,@regs=[],[]
    end
  end

  class AluControl < Ast
    attr_accessor :id,:op,:src_a,:src_b,:dest
  end

  class RegControl < Ast
    attr_accessor :id,:ctrl
  end

end
