# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'

module Day08
  class << self
    extend T::Sig

    # I hate all this code but I did my best

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      heights = input.map { |line| line.chars.map(&:to_i) }
      max_i = heights.length
      max_j = T.must(heights.first).length

      top_visible = VisibilityMap[T::Boolean].new(max_i, max_j, false)
      (0...max_j).each do |j|
        max = -1
        (0...max_i).each do |i|
          height = T.must(T.must(heights[i])[j])

          if height > max
            top_visible.set(i, j, true)
            max = height
          end
        end
      end

      right_visible = VisibilityMap[T::Boolean].new(max_i, max_j, false)
      (0...max_i).each do |i|
        max = -1
        (max_j - 1).downto(0).each do |j|
          height = T.must(T.must(heights[i])[j])

          if height > max
            right_visible.set(i, j, true)
            max = height
          end
        end
      end

      bottom_visible = VisibilityMap[T::Boolean].new(max_i, max_j, false)
      (0...max_j).each do |j|
        max = -1
        (max_i - 1).downto(0).each do |i|
          height = T.must(T.must(heights[i])[j])

          if height > max
            bottom_visible.set(i, j, true)
            max = height
          end
        end
      end

      left_visible = VisibilityMap[T::Boolean].new(max_i, max_j, false)
      (0...max_i).each do |i|
        max = -1
        (0...max_j).each do |j|
          height = T.must(T.must(heights[i])[j])

          if height > max
            left_visible.set(i, j, true)
            max = height
          end
        end
      end

      (0...max_i).map do |i|
        visibilities = (0...max_j).map do |j|
          top_visible.get(i, j) || right_visible.get(i, j) || bottom_visible.get(i, j) || left_visible.get(i, j)
        end
        visibilities.select { |visible| visible == true }.count
      end.sum
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      heights = input.map { |line| line.chars.map(&:to_i) }
      max_i = heights.length
      max_j = T.must(heights.first).length

      top_scores = VisibilityMap[Integer].new(max_i, max_j, 0)
      (0...max_j).each do |j|
        (0...max_i).each do |i|
          height = T.must(T.must(heights[i])[j])
          num_smaller = 0

          (i - 1).downto(0).each do |k|
            other_height = T.must(T.must(heights[k])[j])
            num_smaller += 1
            break if other_height >= height
          end

          top_scores.set(i, j, num_smaller)
        end
      end

      bottom_scores = VisibilityMap[Integer].new(max_i, max_j, 0)
      (0...max_j).each do |j|
        (max_i - 1).downto(0).each do |i|
          height = T.must(T.must(heights[i])[j])
          num_smaller = 0

          (i + 1...max_i).each do |k|
            other_height = T.must(T.must(heights[k])[j])
            num_smaller += 1
            break if other_height >= height
          end

          bottom_scores.set(i, j, num_smaller)
        end
      end

      left_scores = VisibilityMap[Integer].new(max_i, max_j, 0)
      (0...max_i).each do |i|
        (0...max_j).each do |j|
          height = T.must(T.must(heights[i])[j])
          num_smaller = 0

          (j - 1).downto(0).each do |k|
            other_height = T.must(T.must(heights[i])[k])
            num_smaller += 1
            break if other_height >= height
          end

          left_scores.set(i, j, num_smaller)
        end
      end

      right_scores = VisibilityMap[Integer].new(max_i, max_j, 0)
      (0...max_i).each do |i|
        (max_j - 1).downto(0).each do |j|
          height = T.must(T.must(heights[i])[j])
          num_smaller = 0

          (j + 1...max_j).each do |k|
            other_height = T.must(T.must(heights[i])[k])
            num_smaller += 1
            break if other_height >= height
          end

          right_scores.set(i, j, num_smaller)
        end
      end

      T.must((0...max_i).map do |i|
        (0...max_j).map do |j|
          top_scores.get(i, j) * right_scores.get(i, j) * bottom_scores.get(i, j) * left_scores.get(i, j)
        end.max
      end.max)
    end
  end

  class VisibilityMap
    extend T::Sig
    extend T::Generic

    Elem = type_member

    sig { params(height: Integer, width: Integer, base: Elem).void }
    def initialize(height, width, base)
      @map = T.let(
        Array.new(height) do
          Array.new(width, base)
        end,
        T::Array[T::Array[Elem]]
      )
      @height = T.let(@map.length, Integer)
      @width = T.let(T.must(@map.first).length, Integer)
    end

    sig { returns(String) }
    def to_s
      @map.map { |row| row.join(' ') }.join("\n")
    end

    sig { params(i: Integer, j: Integer).returns(Elem) }
    def get(i, j)
      raise "#{i} is an invalid y value" if i.negative? || i >= @height
      raise "#{j} is an invalid x value" if j.negative? || j >= @width

      T.must(@map.dig(i, j))
    end

    sig { params(i: Integer, j: Integer, val: Elem).void }
    def set(i, j, val)
      raise "#{i} is an invalid y value" if i.negative? || i >= @height
      raise "#{j} is an invalid x value" if j.negative? || j >= @width

      T.must(@map[i])[j] = val
    end
  end
end
