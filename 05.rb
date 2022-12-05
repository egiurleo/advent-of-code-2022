# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'

module Day05
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(String) }
    def part_one(input)
      crane = CrateMover9000.new(input)
      crane.move_cargo
      crane.secret_message
    end

    sig { params(input: T::Array[String]).returns(String) }
    def part_two(input)
      crane = CrateMover9001.new(input)
      crane.move_cargo
      crane.secret_message
    end
  end

  class Crate
    extend T::Sig

    sig { returns(String) }
    attr_reader :name

    sig { params(name: String).void }
    def initialize(name)
      @name = T.let(name, String)
    end

    sig { returns(String) }
    def to_s
      "[#{@name}]"
    end
  end

  class Stack
    extend T::Sig
    extend T::Generic

    Elem = type_member { { upper: Object } }

    sig { params(name: String).void }
    def initialize(name)
      @name = T.let(name, String)
      @stack = T.let([], T::Array[Elem])
    end

    sig { params(item: Elem).void }
    def push(item)
      @stack.unshift(item)
    end

    sig { returns(T.nilable(Elem)) }
    def pop
      @stack.shift
    end

    sig { returns(T.nilable(Elem)) }
    def peek
      @stack.first
    end

    sig { returns(String) }
    def to_s
      "#{@name}: " + @stack.reverse.map(&:to_s).join(' ')
    end
  end

  class Instruction
    extend T::Sig

    sig { returns(Integer) }
    attr_reader :number

    sig { returns(String) }
    attr_reader :from_stack

    sig { returns(String) }
    attr_reader :to_stack

    sig { params(number: Integer, from_stack: String, to_stack: String).void }
    def initialize(number:, from_stack:, to_stack:)
      @number = T.let(number, Integer)
      @from_stack = T.let(from_stack, String)
      @to_stack = T.let(to_stack, String)
    end

    sig { params(str: String).returns(Instruction) }
    def self.from_string(str)
      words = str.split
      raise "Invalid string: #{str}" unless words.length == 6

      number = T.must(words[1]).to_i
      from_stack = T.must(words[3])
      to_stack = T.must(words[5])

      new(number:, from_stack:, to_stack:)
    end

    sig { returns(String) }
    def to_s
      "move #{number} from #{from_stack} to #{to_stack}"
    end
  end

  class CrateMover9000
    extend T::Sig

    sig { params(input: T::Array[String]).void }
    def initialize(input)
      blank_line_index = T.must(input.index(""))
      stack_lines = T.must(input[0 ... blank_line_index])
      instruction_lines = T.must(input[blank_line_index + 1 ...])

      @stacks = T.let(
        construct_stacks(stack_lines),
        T::Hash[String, Stack[Crate]]
      )

      @instructions = T.let(
        construct_instructions(instruction_lines),
        T::Array[Instruction]
      )
    end

    sig { void }
    def move_cargo
      @instructions.each do |instruction|
        process_instruction(instruction)
      end
    end

    sig { returns(String) }
    def secret_message
      @stacks.values.map { |stack| T.must(stack.peek) }.map(&:name).join
    end

    sig { returns(String) }
    def to_s
      @stacks.values.map(&:to_s).join("\n")
    end

    private

    sig { params(instruction: Instruction).void }
    def process_instruction(instruction)
      from_stack = T.must(@stacks[instruction.from_stack])
      to_stack = T.must(@stacks[instruction.to_stack])
      number = instruction.number

      number.times do
        crate = T.must(from_stack.pop)
        to_stack.push(crate)
      end
    end

    sig { params(lines: T::Array[String]).returns(T::Hash[String, Stack[Crate]]) }
    def construct_stacks(lines)
      stack_names = T.must(lines.last).split

      stacks = stack_names.each_with_object({}) do |name, hash|
        hash[name] = Stack[Crate].new(name)
      end

      crate_lines = T.must(lines[0...lines.length - 1]).reverse

      crate_lines.each do |line|
        stack_names.each_with_index do |name, idx|
          stack = stacks[name]
          crate_name = line[idx + (idx * 3) + 1]
          next if crate_name == ' ' || crate_name.nil?

          stack.push(Crate.new(crate_name))
        end
      end

      stacks
    end

    sig { params(lines: T::Array[String]).returns(T::Array[Instruction]) }
    def construct_instructions(lines)
      lines.map { |line| Instruction.from_string(line) }
    end
  end

  class CrateMover9001 < CrateMover9000
    private

    sig { params(instruction: Instruction).void }
    def process_instruction(instruction)
      from_stack = T.must(@stacks[instruction.from_stack])
      to_stack = T.must(@stacks[instruction.to_stack])
      number = instruction.number

      crates = number.times.map { T.must(from_stack.pop) }
      crates.reverse.each { |crate| to_stack.push(crate) }
    end
  end
end
