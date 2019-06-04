require 'sxp'

require_relative 'version'
require_relative 'ast'
require_relative 'parser'
require_relative 'code_gen'

module Fidelio

  class Compiler
    attr_accessor :options

    def header
      puts "Fidelio NISC compiler - version #{VERSION}"
    end

    def compile sexpfile
      header
      puts "=> parsing '#{sexpfile}'"
      ast=Parser.new.parse(sexpfile)
      #pp ast
      microcode=CodeGenerator.new.generate_from(ast)
    end

  end
end
