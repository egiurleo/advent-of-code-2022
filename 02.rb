# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'

module Day02
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      solve(input, Mode::Moves)
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      solve(input, Mode::Outcomes)
    end

    private

    sig { params(input: T::Array[String], mode: Mode).returns(Integer) }
    def solve(input, mode)
      input_pairs = input.map do |line|
        input1, input2 = line.split
        [T.must(input1), T.must(input2)]
      end

      tournament = Tournament.new(input_pairs, mode:)
      tournament.play
      tournament.player2_score
    end
  end

  class Move < T::Enum
    extend T::Sig

    enums do
      Rock = new
      Paper = new
      Scissors = new
    end

    sig { returns(Integer) }
    def score
      case self
      when Rock then 1
      when Paper then 2
      when Scissors then 3
      end
    end
  end

  class Outcome < T::Enum
    extend T::Sig

    enums do
      Win = new
      Lose = new
      Draw = new
    end

    sig { returns(Integer) }
    def score
      case self
      when Lose then 0
      when Draw then 3
      when Win then 6
      end
    end
  end

  class Mode < T::Enum
    enums do
      Moves = new
      Outcomes = new
    end
  end

  class Tournament
    extend T::Sig

    sig { params(input_pairs: T::Array[[String, String]], mode: Mode).void }
    def initialize(input_pairs, mode: Mode::Moves)
      @rounds = T.let(construct_rounds(input_pairs, mode), T::Array[Round])

      @player1_score = T.let(0, Integer)
      @player2_score = T.let(0, Integer)
      @played = T.let(false, T::Boolean)
    end

    sig { void }
    def play
      @rounds.each do |round|
        @player1_score += round.player1_score
        @player2_score += round.player2_score
      end

      @played = true
    end

    sig { returns(Integer) }
    def player1_score
      raise "Haven't played tournament yet!" unless @played

      @player1_score
    end

    sig { returns(Integer) }
    def player2_score
      raise "Haven't played tournament yet!" unless @played

      @player2_score
    end

    private

    sig { params(input_pairs: T::Array[[String, String]], mode: Mode).returns(T::Array[Round]) }
    def construct_rounds(input_pairs, mode)
      input_pairs.map do |input_pair|
        input1, input2 = input_pair

        move1 = MoveFactory.build(input1)
        move2 = case mode
                when Mode::Outcomes
                  MoveFactory.build_from_outcome(input2, move1)
                when Mode::Moves
                  MoveFactory.build_encrypted(input2)
                end

        Round.new(move1, move2)
      end
    end
  end

  class Round
    extend T::Sig

    sig { params(move1: Move, move2: Move).void }
    def initialize(move1, move2)
      @move1 = T.let(move1, Move)
      @move2 = T.let(move2, Move)
    end

    sig { returns(Integer) }
    def player1_score
      outcome = OutcomeFactory.build(@move1, @move2)
      @move1.score + outcome.score
    end

    sig { returns(Integer) }
    def player2_score
      outcome = OutcomeFactory.build(@move2, @move1)
      @move2.score + outcome.score
    end
  end

  class MoveFactory
    MOVES = T.let(
      {
        A: Move::Rock,
        B: Move::Paper,
        C: Move::Scissors
      },
      T::Hash[Symbol, Move]
    )

    ENCRYPTED_MOVES = T.let(
      {
        X: Move::Rock,
        Y: Move::Paper,
        Z: Move::Scissors
      },
      T::Hash[Symbol, Move]
    )

    OUTCOMES = T.let(
      {
        X: Outcome::Lose,
        Y: Outcome::Draw,
        Z: Outcome::Win
      },
      T::Hash[Symbol, Outcome]
    )

    class << self
      extend T::Sig
      sig { params(symbol: String).returns(Move) }
      def build(symbol)
        move = MOVES[symbol.to_sym]
        raise "Invalid symbol: #{symbol}" if move.nil?

        move
      end

      sig { params(symbol: String).returns(Move) }
      def build_encrypted(symbol)
        move = ENCRYPTED_MOVES[symbol.to_sym]
        raise "Invalid encrypted symbol: #{symbol}" if move.nil?

        move
      end

      sig { params(symbol: String, other_move: Move).returns(Move) }
      def build_from_outcome(symbol, other_move)
        outcome = OUTCOMES[symbol.to_sym]
        raise "Invalid symbol: #{symbol}" if outcome.nil?

        return other_move if outcome == Outcome::Draw

        case other_move
        when Move::Rock
          outcome == Outcome::Win ? Move::Paper : Move::Scissors
        when Move::Paper
          outcome == Outcome::Win ? Move::Scissors : Move::Rock
        when Move::Scissors
          outcome == Outcome::Win ? Move::Rock : Move::Paper
        end
      end
    end
  end

  class OutcomeFactory
    class << self
      extend T::Sig

      sig { params(move1: Move, move2: Move).returns(Outcome) }
      def build(move1, move2)
        case move1
        when Move::Rock
          case move2
          when Move::Rock
            Outcome::Draw
          when Move::Paper
            Outcome::Lose
          when Move::Scissors
            Outcome::Win
          else
            T.absurd(move2)
          end
        when Move::Paper
          case move2
          when Move::Rock
            Outcome::Win
          when Move::Paper
            Outcome::Draw
          when Move::Scissors
            Outcome::Lose
          else
            T.absurd(move2)
          end
        when Move::Scissors
          case move2
          when Move::Rock
            Outcome::Lose
          when Move::Paper
            Outcome::Win
          when Move::Scissors
            Outcome::Draw
          else
            T.absurd(move2)
          end
        else
          T.absurd(move1)
        end
      end
    end
  end
end
