# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'

module Day14
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      grid = Grid.new

      coords = input.map do |line|
        line.split(" -> ")
      end.flatten.map do |coord_string|
        x, y = coord_string.split(",")
        [T.must(x).to_i, T.must(y).to_i]
      end

      coords.each_cons(2) do |coord1, coord2|
        x1, y1 = T.must(coord1)
        x2, y2 = T.must(coord2)

        if x1 == x2
          miny, maxy = [y1, y2].sort

          (miny..maxy).each do |y|
            grid.set(x1, y, Rock.new)
          end
        elsif y1 == y2
          minx, maxx = [x1, x2].sort

          (minx..maxx).each do |x|
            grid.set(x, y1, Rock.new)
          end
        end
      end

      grid.set(500, 0, Sand.new)
      sand_location = T.let([500, 0], [Integer, Integer])
      sand_num = 0

      while !grid.void?(sand_location)
        next_location = grid.next_location(sand_location)

        if next_location.nil?
          sand_num += 1
          grid.set(500, 0, Sand.new)
          sand_location = [500, 0]
        else
          grid.move(sand_location, next_location)
          sand_location = next_location
        end
      end

        puts grid.to_s + "\n\n"
      sand_num
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      raise NotImplementedError
    end
  end

  class CaveObject; end
  class Rock < CaveObject; end
  class Sand < CaveObject; end

  class Grid
    extend T::Sig

    sig { void }
    def initialize
      @grid = T.let({}, T::Hash[[Integer, Integer], CaveObject])
    end

    sig { params(coord1: [Integer, Integer], coord2: [Integer, Integer]).void }
    def move(coord1, coord2)
      x1, y1 = coord1
      x2, y2 = coord2
      set(x2, y2, T.must(@grid.delete([x1, y1])))
    end

    sig { params(x: Integer, y: Integer, object: CaveObject).void }
    def set(x, y, object)
      @grid[[x, y]] = object
    end

    sig { params(coord: [Integer, Integer]).returns(T::Boolean) }
    def void?(coord)
      coord[1] >= largest_y
    end

    sig { params(x: Integer, y: Integer).returns(T::Boolean) }
    def occupied?(x, y)
      @grid[[x, y]].is_a?(CaveObject)
    end

    sig { params(coord: [Integer, Integer]).returns(T.nilable([Integer, Integer])) }
    def next_location(coord)
      x, y = coord

      [[x, y + 1], [x - 1, y + 1], [x + 1, y + 1]].each do |coord|
        return coord unless occupied?(coord[0], coord[1])
      end

      nil
    end

    sig { returns(String) }
    def to_s
      minx = T.must(@grid.keys.min_by { |x, y| x})[0]
      maxx = T.must(@grid.keys.max_by { |x, y| x})[0]
      miny = T.must(@grid.keys.min_by { |x, y| y})[1]
      maxy = T.must(@grid.keys.max_by { |x, y| y})[1]

      (miny..maxy).map do |y|
        (minx..maxx).map do |x|
          case @grid[[x, y]]
          when nil then "."
          when Rock then "#"
          when Sand then "o"
          end
        end.join
      end.join("\n")
    end

    private

    sig { returns(Integer) }
    def largest_y
      @largetst_y ||= T.let(T.must(@grid.keys.max_by { |x, y| y})[1], T.nilable(Integer))
    end
  end
end
