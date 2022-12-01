# frozen_string_literal: true
# typed: strong

require 'sorbet-runtime'

module Day01
  class << self
    extend T::Sig
    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      elves = generate_elves(input)
      max_elf = elves.max_by(&:total_calories)

      T.must(max_elf).total_calories
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      elves = generate_elves(input)
      max_elves = elves.max_by(3, &:total_calories)
      max_elves.sum(&:total_calories)
    end

    private

    sig { params(input: T::Array[String]).returns(T::Array[Elf]) }
    def generate_elves(input)
      elves = []
      current_lines = []

      input.each do |line|
        if line.empty?
          elves << Elf.new(current_lines)
          current_lines = []
          next
        end

        current_lines << line.strip.to_i
      end

      elves
    end
  end

  class Elf
    extend T::Sig

    sig { params(calories: T::Array[Integer]).void }
    def initialize(calories)
      @calories = calories
    end

    sig { returns(Integer) }
    def total_calories
      @calories.sum
    end
  end
end
