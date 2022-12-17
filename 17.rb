# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'
require 'debug'

module Day17
  extend T::Sig
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      directions = T.must(input.first).chars.map { |char| Direction.deserialize(char) }

      chamber = Chamber.new
      rocks_at_rest = 0
      idx = 0

      rock = Rock.new(T.must(ROCK_SHAPE_ORDER[0]))
      position = rock.shape.starting_position(0)

      while rocks_at_rest < 2022
        if idx.even? # push
          direction = T.must(directions[(idx / 2) % directions.length])
          position = chamber.push(rock, position, direction)
        else # drop
          next_position = chamber.drop(rock, position)

          if next_position.nil?
            rocks_at_rest += 1

            new_shape = T.must(ROCK_SHAPE_ORDER[rocks_at_rest % ROCK_SHAPE_ORDER.length])
            rock = Rock.new(new_shape)
            position = rock.shape.starting_position(chamber.highest_rock)
          else
            position = next_position
          end
        end

        idx += 1
      end

      chamber.highest_rock
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      raise NotImplementedError
    end
  end

  Coord = T.type_alias { [Integer, Integer] }

  class RockShape < T::Enum
    extend T::Sig

    enums do
      Horizontal = new
      Cross = new
      J = new
      Vertical = new
      Square = new
    end

    sig { returns(T::Array[Coord]) }
    def coords
      case self
      when Cross
        [
          [0, 0],
          [0, 1],
          [0, 2],
          [-1, 1],
          [1, 1]
        ]
      when Horizontal
        [
          [0, 0],
          [1, 0],
          [2, 0],
          [3, 0]
        ]
      when J
        [
          [0, 0],
          [1, 0],
          [2, 0],
          [2, 1],
          [2, 2]
        ]
      when Square
        [
          [0, 0],
          [1, 0],
          [0, 1],
          [1, 1]
        ]
      when Vertical
        [
          [0, 0],
          [0, 1],
          [0, 2],
          [0, 3]
        ]
      else T.absurd(self)
      end
    end

    sig { params(highest_rock: Integer).returns(Coord) }
    def starting_position(highest_rock)
      x = self === Cross ? 3 : 2
      [x, highest_rock + 4]
    end
  end

  ROCK_SHAPE_ORDER = T.let(
    [
      RockShape::Horizontal,
      RockShape::Cross,
      RockShape::J,
      RockShape::Vertical,
      RockShape::Square
    ],
    T::Array[RockShape]
  )

  class Direction < T::Enum
    extend T::Sig

    enums do
      Right = new('>')
      Left = new('<')
    end

    sig { params(coord: Coord).returns(Coord) }
    def transform(coord)
      case self
      when Right then [coord[0] + 1, coord[1]]
      when Left then [coord[0] - 1, coord[1]]
      else T.absurd(self)
      end
    end
  end

  class Rock
    extend T::Sig

    sig { returns(RockShape) }
    attr_reader :shape

    sig { params(shape: RockShape).void }
    def initialize(shape)
      @at_rest = T.let(false, T::Boolean)
      @shape = T.let(shape, RockShape)
    end

    sig { void }
    def rest
      @at_rest = true
    end

    sig { params(starting_coord: Coord).returns(T::Array[Coord]) }
    def coords(starting_coord)
      @shape.coords.map do |rock_coord|
        [starting_coord[0] + rock_coord[0], starting_coord[1] + rock_coord[1]]
      end
    end

    sig { params(starting_coord: Coord).returns(Integer) }
    def highest_point(starting_coord)
      coords(starting_coord).map(&:last).max || 0
    end
  end

  class Chamber
    extend T::Sig

    sig { returns(Integer) }
    attr_reader :highest_rock

    sig { void }
    def initialize
      @grid = T.let(Hash.new(false), T::Hash[Coord, T::Boolean])
      @highest_rock = T.let(0, Integer)
    end

    sig { params(coord: Coord, rock: Rock).void }
    def set(coord, _rock)
      raise "Invalid coordinate: #{coord[0]}, #{coord[1]}" if coord[0] > 6
    end

    sig { params(rock: Rock, current_position: Coord, direction: Direction).returns(Coord) }
    def push(rock, current_position, direction)
      next_position = direction.transform(current_position)
      next_coords = rock.coords(next_position)

      return current_position if next_coords.any? { |coord| occupied?(coord) || out_of_bounds?(coord) }

      next_position
    end

    sig { params(rock: Rock, current_position: Coord).returns(T.nilable(Coord)) }
    def drop(rock, current_position)
      next_position = [current_position[0], current_position[1] - 1]
      next_coords = rock.coords(next_position)

      if next_coords.any? { |coord| occupied?(coord) || floor?(coord) }
        rock_coords = rock.coords(current_position)

        rock_coords.each do |coord|
          @grid[coord] = true
        end

        highest_point = rock_coords.map(&:last).max || 0
        @highest_rock = highest_point if highest_point > @highest_rock

        return nil
      end

      next_position
    end

    sig { params(coord: Coord).returns(T::Boolean) }
    def occupied?(coord)
      !!@grid[coord]
    end

    sig { params(coord: Coord).returns(T::Boolean) }
    def floor?(coord)
      (coord[1]).zero?
    end

    sig { params(coord: Coord).returns(T::Boolean) }
    def out_of_bounds?(coord)
      (coord[0]).negative? || coord[0] > 6
    end

    sig { params(rock: Rock, rock_position: Coord).returns(String) }
    def to_s(rock, rock_position)
      rock_coords = rock.coords(rock_position)

      rock.highest_point(rock_position).downto(0).map do |y|
        (0..6).map do |x|
          if rock_coords.include?([x, y])
            '@'
          elsif y.zero?
            '-'
          else
            occupied?([x, y]) ? '#' : '.'
          end
        end.join
      end.join("\n")
    end
  end
end
