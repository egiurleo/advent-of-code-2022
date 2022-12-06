# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'

module Day06
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      input = T.must(input.first)
      solve(input, 4)
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      input = T.must(input.first)
      solve(input, 14)
    end

    private

    sig { params(input: String, number: Integer).returns(Integer) }
    def solve(input, number)
      input.chars.each_cons(number).with_index do |chars, idx|
        return idx + number if chars.uniq.length == chars.length
      end

      raise 'Cannot find start-of-packet marker!'
    end
  end
end
