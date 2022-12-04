# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'

module Day04
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      range_pairs(input).count do |range1, range2|
        range1.cover?(range2) || range2.cover?(range1)
      end
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      range_pairs(input).count do |range1, range2|
        range1.cover?(range2.end) || range2.cover?(range1.end)
      end
    end

    private

    sig do
      params(input: T::Array[String])
        .returns(
          T::Array[[T::Range[Integer], T::Range[Integer]]]
        )
    end
    def range_pairs(input)
      input.map do |line|
        range_str1, range_str2 = line.split(',')
        [
          construct_range(T.must(range_str1)),
          construct_range(T.must(range_str2))
        ]
      end
    end

    sig { params(str: String).returns(T::Range[Integer]) }
    def construct_range(str)
      start, finish = str.split('-')
      Range.new(start.to_i, finish.to_i)
    end
  end
end
