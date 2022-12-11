# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'

module Day10
  class << self
    extend T::Sig

    IMPORTANT_CYCLES = T.let([20, 60, 100, 140, 180, 220], T::Array[Integer])

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      instructions = input.map { |line| Instruction.from_string(line) }

      cpu = CPU.new(instructions)
      signal_strengths = 0

      220.times do |idx|
        signal_strengths += (idx + 1) * cpu.X if IMPORTANT_CYCLES.include?(idx + 1)

        cpu.cycle
      end

      signal_strengths
    end

    sig { params(input: T::Array[String]).void }
    def part_two(input)
      instructions = input.map { |line| Instruction.from_string(line) }
      cpu = CPU.new(instructions)
      crt = CRT.new

      240.times do
        crt.draw((cpu.X - 1..cpu.X + 1))
        cpu.cycle
      end

      puts crt.to_s
    end
  end

  class CPU
    extend T::Sig

    # rubocop:disable Naming/MethodName
    sig { returns Integer }
    attr_reader :X

    sig { params(X: Integer).void }
    attr_writer :X
    # rubocop:enable Naming/MethodName

    sig { params(instructions: T::Array[Instruction]).void }
    def initialize(instructions)
      @X = T.let(1, Integer) # rubocop:disable Naming/VariableName
      @cycle = T.let(0, Integer)
      @instructions = T.let(instructions, T::Array[Instruction])
      @idx = T.let(0, Integer)
    end

    sig { void }
    def cycle
      curr_inst = T.must(@instructions[@idx])
      response = curr_inst.cycle(self)

      case response
      when Response::NextInstruction then @idx += 1
      when Response::Again
      else T.absurd(response)
      end
    end
  end

  class Response < T::Enum
    enums do
      Again = new
      NextInstruction = new
    end
  end

  class Instruction
    extend T::Sig
    extend T::Helpers

    abstract!

    sig { abstract.params(cpu: CPU).returns(Response) }
    def cycle(cpu); end

    sig { params(str: String).returns(Instruction) }
    def self.from_string(str)
      parts = str.split
      name = T.must(parts[0])

      case name
      when 'noop'
        Noop.new
      when 'addx'
        number = T.must(parts[1]).to_i
        AddX.new(number)
      else
        raise "Invalid instruction: #{name}"
      end
    end
  end

  class Noop < Instruction
    extend T::Sig

    sig { override.params(_: CPU).returns(Response) }
    def cycle(_)
      Response::NextInstruction
    end
  end

  class AddX < Instruction
    extend T::Sig

    sig { params(number: Integer).void }
    def initialize(number)
      @number = T.let(number, Integer)
      @cycle = T.let(0, Integer)

      super()
    end

    sig { override.params(cpu: CPU).returns(Response) }
    def cycle(cpu)
      case @cycle
      when 0
        @cycle += 1
        Response::Again
      when 1
        cpu.X += @number
        Response::NextInstruction
      else
        raise 'No more cycles left on AddX instruction'
      end
    end
  end

  class CRT
    extend T::Sig

    WIDTH = T.let(40, Integer)
    HEIGHT = T.let(6, Integer)

    sig { void }
    def initialize
      @screen = T.let({}, T::Hash[[Integer, Integer], String])
      @x = T.let(0, Integer)
      @y = T.let(0, Integer)
    end

    sig { params(range: T::Range[Integer]).void }
    def draw(range)
      @screen[[@x, @y]] = if range.cover?(@x)
                            '#'
                          else
                            '.'
                          end

      if @x == WIDTH - 1
        @x = 0
        @y += 1
      else
        @x += 1
      end
    end

    sig { returns(String) }
    def to_s
      HEIGHT.times.map do |y|
        WIDTH.times.map do |x|
          @screen[[x, y]] || ' '
        end.join
      end.join("\n")
    end
  end
end
