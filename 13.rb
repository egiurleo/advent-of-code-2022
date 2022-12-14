# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'

module Day13
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      packet_groups = T.let([], T::Array[[Packet, Packet]])

      input.each_slice(3) do |lines|
        line1 = T.must(lines[0])
        line2 = T.must(lines[1])

        packet_groups << [Packet.from_string(line1), Packet.from_string(line2)]
      end

      correct_indices = []
      (0...packet_groups.length).each do |idx|
        packet_group = T.must(packet_groups[idx])
        packet1, packet2 = packet_group

        correct_indices << (idx + 1) if packet1 <= packet2
      end

      correct_indices.reduce(&:+)
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      packets = input.map do |line|
        Packet.from_string(line) unless line == ''
      end.compact

      divider_packet1 = Packet.from_string('[[2]]')
      divider_packet2 = Packet.from_string('[[6]]')

      packets << divider_packet1
      packets << divider_packet2

      packets.sort!

      (T.must(packets.index(divider_packet1)) + 1) * (T.must(packets.index(divider_packet2)) + 1)
    end
  end

  class Packet
    include Comparable
    extend T::Sig

    sig { returns(T::Array[T.any(Integer, Packet)]) }
    attr_reader :data

    sig { params(data: T::Array[T.any(Integer, Packet)]).void }
    def initialize(data)
      @data = T.let(data, T::Array[T.any(Integer, Packet)])
    end

    sig { params(string: String).returns(Packet) }
    def self.from_string(string)
      string = T.must(string[1...string.length - 1].dup)
      data = []

      curr_string = ''
      open_brackets = 0
      idx = 0
      while idx < string.length
        if string[idx] == ',' && open_brackets.zero?
          if curr_string.include?('[')
            data << Packet.from_string(curr_string)
          elsif curr_string.match(/\d/)
            data << curr_string.to_i
          end

          curr_string = ''
        elsif string[idx] == '['
          open_brackets += 1
          curr_string += T.must(string[idx])
        elsif string[idx] == ']'
          open_brackets -= 1
          curr_string += T.must(string[idx])
        else
          curr_string += T.must(string[idx])
        end

        idx += 1
      end

      if curr_string.include?('[')
        data << Packet.from_string(curr_string)
      elsif curr_string.match(/\d/)
        data << curr_string.to_i
      end

      Packet.new(data)
    end

    sig { params(other: T.any(Packet, Integer)).returns(Integer) }
    def <=>(other)
      return self <=> Packet.new([other]) if other.is_a?(Integer)

      @data.each.with_index do |mine, idx|
        return 1 if other.data.length <= idx

        theirs = T.must(other.data[idx])

        if mine.is_a?(Integer) && theirs.is_a?(Integer)
          return mine <=> theirs unless mine == theirs
        elsif mine.is_a?(Packet) && theirs.is_a?(Packet) # rubocop:disable Lint/DuplicateBranch
          return mine <=> theirs unless mine == theirs
        elsif mine.is_a?(Packet) && theirs.is_a?(Integer)
          return mine <=> theirs
        elsif theirs.is_a?(Packet) && mine.is_a?(Integer)
          comparison = theirs <=> mine
          return comparison * -1 unless comparison.zero?
        end
      end

      @data.length <=> other.data.length
    end

    sig { returns(String) }
    def to_s
      "[#{@data.map(&:to_s).join(',')}]"
    end

    sig { params(other: Object).returns(T::Boolean) }
    def ==(other)
      other.is_a?(self.class) &&
        @data.length == other.data.length &&
        (0...@data.length).all? { |idx| @data[idx] == other.data[idx] }
    end
  end
end
