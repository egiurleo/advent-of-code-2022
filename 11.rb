# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'

module Day11
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      monkeys = construct_monkeys(input)
      20.times { monkeys.each_value(&:turn) }
      monkeys.values.map(&:num_inspections).max(2).reduce(:*)
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      monkeys = construct_monkeys(input)
      lcm = monkeys.values.map(&:test_number).reduce(1, :lcm)
      10_000.times { monkeys.each_value { |monkey| monkey.turn(least_common_multiple: lcm) } }
      monkeys.values.map(&:num_inspections).max(2).reduce(:*)
    end

    private

    sig { params(input: T::Array[String]).returns(T::Hash[Integer, Monkey]) }
    def construct_monkeys(input)
      input = input.dup << '' # Add an empty line to the end of the input to process the final monkey

      lines = []
      idx = 0
      monkeys = T.let({}, T::Hash[Integer, Monkey])

      throw_to = proc { |monkey_no, item| T.must(monkeys[monkey_no]).accept(item) }

      input.each do |line|
        if line == ''
          monkeys[idx] = Monkey.from_strings(T.must(lines[1..]), throw_to)
          idx += 1
          lines = []
        else
          lines << line
        end
      end

      monkeys
    end
  end

  class Item
    extend T::Sig

    sig { returns(Integer) }
    attr_reader :worry_level

    sig { params(worry_level: Integer).void }
    attr_writer :worry_level

    sig { params(worry_level: Integer).void }
    def initialize(worry_level)
      @worry_level = T.let(worry_level, Integer)
    end
  end

  # rubocop:disable Metrics/ParameterLists
  class Monkey
    extend T::Sig

    sig { returns(Integer) }
    attr_reader :num_inspections

    sig { returns(Integer) }
    attr_reader :test_number

    sig do
      params(
        starting_items: T::Array[Item],
        operation: T.proc.params(arg0: Integer).returns(Integer),
        test_number: Integer,
        true_monkey: Integer,
        false_monkey: Integer,
        throw_to: T.proc.params(arg0: Integer, arg1: Item).void
      ).void
    end
    def initialize(starting_items, operation, test_number, true_monkey, false_monkey, throw_to)
      @items = T.let(starting_items, T::Array[Item])
      @operation = T.let(operation, T.proc.params(arg0: Integer).returns(Integer))
      @test_number = T.let(test_number, Integer)
      @true_monkey = T.let(true_monkey, Integer)
      @false_monkey = T.let(false_monkey, Integer)
      @throw_to = T.let(throw_to, T.proc.params(arg0: Integer, arg1: Item).void)
      @num_inspections = T.let(0, Integer)
    end

    sig { params(least_common_multiple: T.nilable(Integer)).void }
    def turn(least_common_multiple: nil)
      while (item = @items.shift)
        inspect(item)
        relief(item, least_common_multiple)
        test_and_throw(item)
      end
    end

    sig { params(item: Item).void }
    def accept(item)
      @items << item
    end

    sig do
      params(
        lines: T::Array[String],
        throw_to: T.proc.params(arg0: Integer, arg1: Item).void
      ).returns(Monkey)
    end
    def self.from_strings(lines, throw_to)
      starting_item_line = T.must(lines.first)
      operation_line = T.must(lines[1])
      test_lines = T.must(lines[2..])

      starting_items = T.must(starting_item_line.split[2..]).map { |worry_level| Item.new(worry_level.to_i) }
      # rubocop:disable Security/Eval
      operation = proc { |worry_level| eval(T.must(operation_line.split(' = ')[1]).gsub('old', worry_level.to_s).to_s) }
      # rubocop:enable Security/Eval

      test_number = T.must(test_lines.first&.split(' ')&.last).to_i
      true_monkey = T.must(test_lines[1]&.split(' ')&.last).to_i
      false_monkey = T.must(test_lines[2]&.split(' ')&.last).to_i

      Monkey.new(starting_items, operation, test_number, true_monkey, false_monkey, throw_to)
    end

    private

    sig { params(item: Item).void }
    def inspect(item)
      item.worry_level = @operation.call(item.worry_level)
      @num_inspections += 1
    end

    sig { params(item: Item, least_common_multiple: T.nilable(Integer)).void }
    def relief(item, least_common_multiple)
      item.worry_level = if least_common_multiple.nil?
                           (item.worry_level / 3).floor
                         else
                           item.worry_level % least_common_multiple
                         end
    end

    sig { params(item: Item).void }
    def test_and_throw(item)
      receiving_monkey = (item.worry_level % @test_number).zero? ? @true_monkey : @false_monkey
      @throw_to.call(receiving_monkey, item)
    end
  end
  # rubocop:enable Metrics/ParameterLists
end
