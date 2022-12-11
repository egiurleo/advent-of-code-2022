# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'

module Day09
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      solve(input, 2)
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      solve(input, 10)
    end

    private

    sig { params(input: T::Array[String], num_knots: Integer).returns(Integer) }
    def solve(input, num_knots)
      instructions = input.map { |line| Instruction.from_string((line)).to_a }.flatten
      rope = Rope.new(num_knots)
      tail = T.must(rope.knots.last)
      positions = { tail.position.coordinates => true }

      instructions.each do |instruction|
        rope.apply(instruction)
        positions[tail.position.coordinates] = true
      end

      positions.keys.length
    end
  end

  Tuple = T.type_alias { [Integer, Integer] }

  class Direction < T::Enum
    enums do
      Right = new('R')
      Down = new('D')
      Left = new('L')
      Up = new('U')
    end
  end

  class Position
    extend T::Sig

    sig { returns(Integer) }
    attr_reader :x

    sig { returns(Integer) }
    attr_reader :y

    sig { params(x: Integer, y: Integer).void }
    def initialize(x, y)
      @x = T.let(x, Integer)
      @y = T.let(y, Integer)
    end

    sig { params(instruction: Instruction).void }
    def apply(instruction)
      direction = instruction.direction
      length = instruction.length

      case direction
      when Direction::Up then @y -= length
      when Direction::Right then @x += length
      when Direction::Down then @y += length
      when Direction::Left then @x -= length
      else
        T.absurd(direction)
      end
    end

    sig { returns(Tuple) }
    def coordinates
      [@x, @y]
    end

    sig { params(other: Position).returns(T::Boolean) }
    def touching?(other)
      (@x - other.x).abs <= 1 && (@y - other.y).abs <= 1
    end
  end

  class Knot
    extend T::Sig

    sig { returns(Position) }
    attr_reader :position

    sig { void }
    def initialize
      @position = T.let(Position.new(0, 0), Position)
    end

    sig { params(instruction: Instruction).void }
    def apply(instruction)
      @position.apply(instruction)
    end
  end

  class Rope
    extend T::Sig

    sig { returns(T::Array[Knot]) }
    attr_reader :knots

    sig { params(num_knots: Integer).void }
    def initialize(num_knots)
      @knots = T.let(
        num_knots.times.map do
          Knot.new
        end,
        T::Array[Knot]
      )
    end

    sig { params(instruction: Instruction).void }
    def apply(instruction)
      head = T.must(@knots.first)
      head.apply(instruction)
      prev = head

      T.must(@knots[1...]).each do |knot|
        break if prev.position.touching?(knot.position)

        x_delta = prev.position.x - knot.position.x
        y_delta = prev.position.y - knot.position.y

        x_instruction = if x_delta.positive?
                          Instruction.new(Direction::Right, 1)
                        elsif x_delta.negative?
                          Instruction.new(Direction::Left, 1)
                        end

        y_instruction = if y_delta.positive?
                          Instruction.new(Direction::Down, 1)
                        elsif y_delta.negative?
                          Instruction.new(Direction::Up, 1)
                        end

        knot.apply(x_instruction) if x_instruction
        knot.apply(y_instruction) if y_instruction

        prev = knot
      end
    end
  end

  class Instruction
    extend T::Sig

    sig { returns(Direction) }
    attr_reader :direction

    sig { returns(Integer) }
    attr_reader :length

    sig { params(direction: Direction, length: Integer).void }
    def initialize(direction, length)
      @direction = T.let(direction, Direction)
      @length = T.let(length, Integer)
    end

    sig { returns(T::Array[Instruction]) }
    def to_a
      [self.class.new(direction, 1)] * @length
    end

    sig { returns(String) }
    def to_s
      "#{@direction.serialize} #{@length}"
    end

    sig { params(string: String).returns(Instruction) }
    def self.from_string(string)
      parts = string.split

      direction = Direction.deserialize(T.must(parts.first))
      length = T.must(parts.last).to_i

      new(direction, length)
    end
  end
end
