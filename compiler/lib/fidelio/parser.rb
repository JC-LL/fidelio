require 'sxp'
require_relative 'ast'

module Fidelio

  class Parser

    attr_accessor :options

    def parse sexpfile
      sexp=SXP.read IO.read(sexpfile)
      ast=objectify(sexp)
    end

    def objectify sexp
      program=Program.new
      sexp.shift
      program.name=sexp[0]
      program.config=parse_config(sexp[1])
      program.controler=parse_controler(sexp[2])
      program
    end

    def expect sexp,klass,value=nil
      unless (kind=sexp.shift).is_a? klass
        puts "ERROR : expecting a #{klass}. Got a #{kind}."
        raise "Syntax error"
      end
      if value
        unless value==kind
          puts "ERROR : expecting value '#{value}'. Got '#{kind}'"
          raise "Syntax error"
        end
      end
      return kind
    end

    def parse_config sexp
      config=Config.new
      expect(sexp,Symbol,:config)
      while sexp.any?
        car=sexp.first.first
        case car
        when :data_width
          config.data_width=parse_single(sexp.first)
        when :regs
          config.regs=parse_single(sexp.first)
        when :states
          config.states=parse_single(sexp.first)
        when :inputs
          config.inputs=parse_inputs(sexp.first)
        when :outputs
          config.outputs=parse_outputs(sexp.first)
        when :status_bits
          config.status_bits=parse_status_bits(sexp.first)
        when :alus
          config.alus=parse_alu_configs(sexp.first)
        else
          puts "ERROR parsing config : expecting one of 'inputs','outputs','regs','data_width','alus','states'"
          puts "                       Got '#{car}'."
          raise "Syntax error"
        end
        sexp.shift
      end
      config
    end

    def parse_single sexp
      #puts "parsing single : #{sexp}" if $VERBOSE
      sexp.shift
      return sexp.shift
    end

    def parse_inputs sexp
      expect(sexp,Symbol,:inputs)
      ret=[]
      while sexp.any?
        ret << parse_input(sexp.shift)
      end
      ret
    end

    def parse_input sexp
      expect(sexp,Symbol,:input)
      inp=Input.new
      inp.id=sexp.shift
      inp.to_reg=parse_single(sexp)
      inp
    end

    def parse_outputs sexp
      expect(sexp,Symbol,:outputs)
      ret=[]
      while sexp.any?
        ret << parse_output(sexp.shift)
      end
      ret
    end

    def parse_output sexp
      expect(sexp,Symbol,:output)
      inp=Output.new
      inp.id=sexp.shift
      inp.from_reg=parse_single(sexp)
      inp
    end

    def parse_alu_configs sexp
      configs=[]
      expect sexp,Symbol,:alus
      while sexp.any?
        configs << parse_alu_config(sexp.shift)
      end
      configs
    end

    def parse_status_bits sexp
      ret=[]
      expect(sexp,Symbol,:status_bits)
      while sexp.any?
        ret << parse_status_bit(sexp.shift)
      end
      ret
    end

    def parse_status_bit sexp
      sb=StatusBit.new
      expect(sexp,Symbol,:status_bit)
      sb.id=expect(sexp,Integer)
      sb.reg=parse_single(sexp.shift)
      sb.pos=parse_single(sexp.shift)
      sb
    end

    def parse_alu_config sexp
      cfg=AluConfig.new
      expect(sexp,Symbol,:alu)
      cfg.id=expect(sexp,Integer)
      cfg.ops=parse_ops(sexp.first)
      cfg
    end

    OPS=[:nop,:add,:sub,:mul,:div,:eq,:neq,:gt,:gte]

    def parse_ops sexp
      ret=[]
      expect(sexp,Symbol,:ops)
      while sexp.any?
        if OPS.include? (op=sexp.first)
          ret << sexp.shift
        else
          puts "ERROR : expecting one of '#{OPS.join(',')}'"
          puts "        Got '#{op}'"
          raise "Syntax error"
        end
      end
      ret
    end

    def parse_controler sexp
      c=Controler.new
      expect(sexp,Symbol,:controler)
      while sexp.any?
        c.states << parse_state(sexp.shift)
      end
      c
    end

    def car sexp
      sexp.first
    end

    def parse_state sexp
      state=State.new
      expect sexp,Symbol,:state
      state.id=expect(sexp,Integer)
      while sexp.any?
        case car(sexp.first)
        when :spec
          state.spec=parse_single(sexp.shift)
        when :jump
          state.jump=parse_jump(sexp.shift)
        when :control
          state.control=parse_control(sexp.shift)
        when :done
          state.done=parse_single(sexp.shift)
        else
          puts "ERROR : expecting one of 'spec','jump','control','done'"
          puts "        Got '#{car(sexp)}'"
          raise "Syntax error"
        end
      end
      state
    end

    def parse_jump sexp
      jump=Jump.new
      expect(sexp,Symbol,:jump)
      jump.next=expect(sexp,Integer)
      while sexp.any?
        case car(sexp.first)
        when :status_mask
          jump.status_mask=parse_single(sexp.shift) #Warn Symbol returned
        when :default
          jump.default=parse_single(sexp.shift)
        else
          puts "ERROR : expecting one of 'status_mask','default'"
          puts "        Got '#{car(sexp.first)}'"
          raise "Syntax error"
        end
      end
      jump
    end

    def parse_control sexp
      ctrl=Control.new
      expect(sexp,Symbol,:control)
      while sexp.any?
        case car(sexp.first)
        when :alu
          ctrl.alus << parse_alu_control(sexp.shift)
        when :reg
          ctrl.regs << parse_reg_control(sexp.shift)
        else
          puts "ERROR controler/control: expecting one of 'alu','reg'"
          puts "                      Got '#{car(sexp.shift)}'"
        end
      end
      ctrl
    end

    def parse_alu_control sexp
      alu_ctrl=AluControl.new
      expect(sexp,Symbol,:alu)
      alu_ctrl.id=expect(sexp,Integer)
      alu_ctrl.op=expect(sexp,Symbol)
      alu_ctrl.src_a=expect(sexp,Symbol)
      alu_ctrl.src_b=expect(sexp,Symbol)
      alu_ctrl.dest =expect(sexp,Symbol)
      alu_ctrl
    end

    def parse_reg_control sexp
      reg_ctrl=RegControl.new
      expect(sexp,Symbol,:reg)
      reg_ctrl.id=expect(sexp,Integer)
      reg_ctrl.ctrl=eval(expect(sexp,Symbol).to_s)
      reg_ctrl
    end


  end
end
