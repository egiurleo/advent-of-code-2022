# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'

module Day03
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      input.map do |line|
        first_half = T.must(line[0...line.length / 2])
        second_half = T.must(line[line.length / 2...])

        Rucksack.new([first_half, second_half]).shared_item.priority
      end.sum
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      input.each_slice(3).map do |line1, line2, line3|
        Rucksack
          .new([T.must(line1), T.must(line2), T.must(line3)])
          .shared_item
          .priority
      end.sum
    end
  end

  class Item
    extend T::Sig

    VALID_SYMBOLS = T.let((:a..:z).to_a + (:A..:Z).to_a, T::Array[Symbol])

    sig { params(symbol: T.any(Symbol, String)).void }
    def initialize(symbol)
      symbol = symbol.to_sym
      raise ArgumentError, "Invalid symbol: #{symbol}" unless VALID_SYMBOLS.include?(symbol)

      @symbol = T.let(symbol.to_sym, Symbol)
    end

    sig { returns(String) }
    def serialize
      @symbol.to_s
    end

    sig { returns(Integer) }
    def priority
      subtraction = upper? ? 38 : 96
      @symbol.to_s.ord - subtraction
    end

    private

    sig { returns(T::Boolean) }
    def upper?
      @symbol.upcase == @symbol
    end
  end

  class Compartment
    extend T::Sig

    sig { params(items: T::Array[Item]).void }
    def initialize(items)
      @item_array = T.let(items, T::Array[Item])

      @item_hash = T.let(
        @item_array.each_with_object({}) do |item, hash|
          hash[item.serialize] = item
        end,
        T::Hash[String, Item]
      )
    end

    sig { params(item: Item).returns(T::Boolean) }
    def contains_item?(item)
      @item_hash.key?(item.serialize)
    end

    sig { returns(T::Array[Item]) }
    def items
      @item_array
    end
  end

  class Rucksack
    extend T::Sig

    sig { params(compartment_strings: T::Array[String]).void }
    def initialize(compartment_strings)
      @compartments = T.let(
        compartment_strings.map { |string| construct_compartment(string) },
        T::Array[Compartment]
      )
    end

    sig { returns(Item) }
    def shared_item
      first_compartment = T.must(@compartments.first)
      last_compartment = T.must(@compartments.last)

      first_compartment.items.each do |item|
        other_compartments = T.must(@compartments[1..])
        other_compartments.each do |other_compartment|
          break unless other_compartment.contains_item?(item)
          return item if other_compartment.contains_item?(item) && other_compartment == last_compartment
        end
      end

      raise 'Compartments do not contain shared item!'
    end

    private

    sig { params(compartment_string: String).returns(Compartment) }
    def construct_compartment(compartment_string)
      items = compartment_string.chars.map { |char| Item.new(char) }
      Compartment.new(items)
    end
  end

  class Group
    extend T::Sig

    sig { params(items1: T::Array[Item], items2: T::Array[Item], items3: T::Array[Item]).void }
    def initialize(items1, items2, items3)
      @compartment1 = T.let(Compartment.new(items1), Compartment)
      @compartment2 = T.let(Compartment.new(items2), Compartment)
      @compartment3 = T.let(Compartment.new(items3), Compartment)
    end

    sig { returns(Item) }
    def shared_item
      @compartment1.items.each do |item|
        next unless @compartment2.contains_item?(item)
        return item if @compartment3.contains_item?(item)
      end

      raise 'Compartments do not contain shared item!'
    end
  end
end
