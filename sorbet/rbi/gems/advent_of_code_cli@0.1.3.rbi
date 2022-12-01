# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `advent_of_code_cli` gem.
# Please instead update this file by running `bin/tapioca gem advent_of_code_cli`.

module AdventOfCode; end

class AdventOfCode::CLI < ::Thor
  # source://advent_of_code_cli//lib/advent_of_code_cli.rb#25
  def download(day); end

  # source://advent_of_code_cli//lib/advent_of_code_cli.rb#17
  def scaffold(day); end

  # source://advent_of_code_cli//lib/advent_of_code_cli.rb#34
  def solve(day); end

  private

  # source://advent_of_code_cli//lib/advent_of_code_cli.rb#46
  def rescue_invalid_day_error; end
end

module AdventOfCode::Commands; end

class AdventOfCode::Commands::Command
  include ::Thor::Base
  include ::Thor::Invocation
  include ::Thor::Shell
  extend ::Thor::Base::ClassMethods
  extend ::Thor::Invocation::ClassMethods

  # @raise [InvalidDayError]
  # @return [Command] a new instance of Command
  #
  # source://advent_of_code_cli//lib/advent_of_code_cli/commands/command.rb#8
  def initialize(day:); end

  private

  # source://advent_of_code_cli//lib/advent_of_code_cli/commands/command.rb#28
  def create_file(file_name, contents = T.unsafe(nil)); end

  # source://advent_of_code_cli//lib/advent_of_code_cli/commands/command.rb#16
  def day_string; end

  # source://advent_of_code_cli//lib/advent_of_code_cli/commands/command.rb#24
  def input_file_name; end

  # source://advent_of_code_cli//lib/advent_of_code_cli/commands/command.rb#20
  def solution_file_name; end
end

class AdventOfCode::Commands::Download < ::AdventOfCode::Commands::Command
  # @return [Download] a new instance of Download
  #
  # source://advent_of_code_cli//lib/advent_of_code_cli/commands/download.rb#9
  def initialize(year:, day:); end

  # @raise [MissingCookieError]
  #
  # source://advent_of_code_cli//lib/advent_of_code_cli/commands/download.rb#14
  def execute; end

  private

  # source://advent_of_code_cli//lib/advent_of_code_cli/commands/download.rb#33
  def cookie; end

  # @return [Boolean]
  #
  # source://advent_of_code_cli//lib/advent_of_code_cli/commands/download.rb#37
  def cookie_present?; end

  # source://advent_of_code_cli//lib/advent_of_code_cli/commands/download.rb#41
  def fetch_input; end
end

class AdventOfCode::Commands::Scaffold < ::AdventOfCode::Commands::Command
  # source://advent_of_code_cli//lib/advent_of_code_cli/commands/scaffold.rb#6
  def execute; end

  private

  # source://advent_of_code_cli//lib/advent_of_code_cli/commands/scaffold.rb#33
  def solution_file_contents; end
end

class AdventOfCode::Commands::Solve < ::AdventOfCode::Commands::Command
  # @raise [MissingInputError]
  #
  # source://advent_of_code_cli//lib/advent_of_code_cli/commands/solve.rb#8
  def execute; end

  private

  # source://advent_of_code_cli//lib/advent_of_code_cli/commands/solve.rb#31
  def solution(module_name, part, input); end
end

class AdventOfCode::Error < ::StandardError; end
class AdventOfCode::InvalidDayError < ::AdventOfCode::Error; end
class AdventOfCode::MissingCookieError < ::AdventOfCode::Error; end
class AdventOfCode::MissingInputError < ::AdventOfCode::Error; end
class AdventOfCode::MissingSolutionError < ::AdventOfCode::Error; end

# source://advent_of_code_cli//lib/advent_of_code_cli/version.rb#4
AdventOfCode::VERSION = T.let(T.unsafe(nil), String)
