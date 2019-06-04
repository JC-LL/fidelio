
module Fidelio

  class CodeGenerator

    def generate_from program
      puts "=> generating code for program '#{program.name}'"
      config=program.config
      format_h=format_computing(config)
      states_h=params_gathering(program.controler)
      program_s=encode_program(format_h,states_h)
      puts "=> binary program (with 'u'nknown values)"
      pp program_s

      puts "=> binary program : (bitwidth #{@word_size})"
      program_bs=program_s.map{|code| code.gsub(/u/,'0')}
      pp program_bs
      program_bs=program_bs.map{|code| code.gsub(/-/,'')}
      pp program_bs

      n_digits_hexa=(@word_size / 4.to_f).ceil
      puts "=> hexa  program : (#{n_digits_hexa} hexa digits needed)"
      program_hex=program_bs.map{|code| code.to_i(2).to_s(16).rjust(n_digits_hexa,'0')}
      pp program_hex
      save_as(program_hex,filename="#{program.name.downcase}.hex")
    end

    def save_as hexa_a,filename
      puts "=> saving as '#{filename}'"
      #justify=(Math.log(hexa_a.size)/Math.log(16)).ceil
      justify=32/4
      File.open(filename,'w') do |file|
        hexa_a.each_with_index do |instr,address|
          file.puts p "#{address.to_s(16).rjust(justify,'0')} #{instr}"
        end
      end
    end

    def params_gathering controler
      puts "=> gathering params for states"
      params_h={}
      controler.states.each do |state|
        params_h[state.id]=state_params(state)
      end
      params_h
    end

    def state_params state
      puts "   -state #{state.id}" if $VERBOSE
      h={}
      h.merge!(jump_params(state))
      h.merge!(datapath_control_params(state))
      pp h if $VERBOSE
      h
    end

    def format_computing config
      puts "=> compute µ-instruction format"
      format={}
      format[:mask]=config.status_bits.size
      format[:addr]=log2ceil(config.states)
      format[:done]=1
      format[:default]=1
      config.alus.each do |alu|
        format["alu_#{alu.id}_op".to_sym   ]=log2ceil(CODEOP.size)
        format["alu_#{alu.id}_src_a".to_sym]=log2ceil(config.regs)
        format["alu_#{alu.id}_src_b".to_sym]=log2ceil(config.regs)
        format["alu_#{alu.id}_dest".to_sym ]=log2ceil(config.regs)
      end
      (0..config.regs-1).each do |reg|
        format["reg_#{reg}_ctrl".to_sym ]=3
      end

      format.each do |key,value|
        puts "   -#{key.to_s.ljust(15,'.')}#{value}"
      end
      puts "   "+"-"*25
      @word_size=format.values.sum
      puts "   -width........#{(w=@word_size).to_s.rjust(5,'.')         } bits"
      puts "   -heigth.......#{(h=config.states.to_i).to_s.rjust(5,'.')} words"
      total_bits=w*h
      puts "   -total........#{total_bits.to_s.rjust(5,'.')            } bits"
      format
    end

    def log2ceil x
        Math.log2(x).ceil
    end

    def jump_params state
      h={}
      if state.jump
        h[:addr]=state.jump.next
        h[:mask]=eval(state.jump.status_mask.to_s) # symbol :"0b011" => 3
        h[:default]=encode_default(state)
      else
        if state.done
          h[:done]=1
        else
          raise "ERROR : no (jump ...) nor (done true) in state #{state.id}"
        end
      end
      h
    end

    def encode_default state
      current=state.id
      if state.jump.default
        next_default=state.jump.default
        if next_default==current+1
          return 0b1
        elsif next_default==current
          return 0b0
        else
          puts "ERROR in state #{state.id} : (default x) is in this case either #{current} or #{current+1}"
          puts "     Found : #{state.jump.default}"
          raise "Semantic error"
        end
      else
        return 0b0
      end
    end

    def datapath_control_params state
      h={}
      if state.control
        if state.control
          for alu in state.control.alus
            h.merge! params_alu_ctrl(alu)
          end
          for reg in state.control.regs
            h.merge! params_reg_ctrl(reg)
          end
        end
      else
      end
      h
    end

    def params_alu_ctrl alu
      h={}
      h["alu_#{alu.id}_op".to_sym]    = CODEOP[alu.op]
      h["alu_#{alu.id}_src_a".to_sym] = encode_reg(alu.src_a)
      h["alu_#{alu.id}_src_b".to_sym] = encode_reg(alu.src_b)
      h["alu_#{alu.id}_dest".to_sym ] = encode_reg(alu.dest)
      h
    end

    REG_FORMAT=/[rR]?(\d+)/
    def encode_reg reg
      return reg if reg.is_a? Integer
      reg_id  =reg.match(REG_FORMAT){|m| m.captures.first.to_i}
    end

    def params_reg_ctrl reg
      h={}
      reg_id   = encode_reg(reg.id)
      value_ctrl=reg.ctrl
      h["reg_#{reg_id}_ctrl".to_sym]=value_ctrl
      h
    end

    # warn : optimization opportunities to be checked
    CODEOP={
      nop: 0b0000,
      add: 0b0001,
      sub: 0b0010,
      mul: 0b0011,
      div: 0b0100,
      mod: 0b0101,
      shl: 0b0110,
      shr: 0b0111,
      or:  0b1000,
      and: 0b1001,
      xor: 0b1010,
      not: 0b1011,
      eq:  0b1100,
      neq: 0b1101,
      gt:  0b1110,
      gte: 0b1111,
    }

    def encode_program format_h,states_h
      puts "=> encode µ-program"
      program_s=[]
      states_h.each do |state_id,params_h|
        puts "#{state_id} -- #{params_h}" if $VERBOSE
        code=encode_params(format_h,params_h)
        code=code.join('-')
        program_s << code
      end
      program_s
    end

    def encode_params format_h,params_h
      code=[]
      format_h.each do |field,nbits|
        if value=params_h[field]
          value_s=value.to_s.to_i.to_s(2).rjust(nbits,'0')
          if value_s.size <= nbits
            code << value_s
            params_h.delete(field)
          else
            puts "ERROR : value is #{value} for field '#{field}', but cannot be encoded on #{nbits} bits,"+
                 "as supposed in the computed format."
            raise "Illegal parameter"
          end
        else
          params_h.delete(field)
          code << "u"*nbits
        end
      end
      if params_h.any?
        puts "ERROR : #{params_h.size} illegal parameter."
        params_h.each do |field,value|
          puts "ERROR : illegal remaining field '#{field}' (value=#{value})"
          raise "Illegal parameter"
        end
      end
      code
    end

  end

end
