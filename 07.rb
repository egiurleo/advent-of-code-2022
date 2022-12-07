# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'

module Day07
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      file_tree = FileTree.new
      instructions = build_instructions(input)

      instructions.each { |inst| inst.execute(file_tree) }
      file_tree.directories_less_than(100_000).sum(&:size)
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      file_tree = FileTree.new
      instructions = build_instructions(input)

      instructions.each { |inst| inst.execute(file_tree) }

      dir = file_tree
            .directories_greater_than(30_000_000 - file_tree.unused_space)
            .min_by(&:size)

      T.must(dir).size
    end

    private

    sig { params(input: T::Array[String]).returns(T::Array[Instruction]) }
    def build_instructions(input)
      instructions = []

      input_group = []
      input.each do |line|
        if input_group.length.positive? && line[0] == '$'
          instructions << InstructionFactory.build_instruction(input_group)
          input_group = []
        end

        input_group << line
      end

      instructions << InstructionFactory.build_instruction(input_group) if input_group.length.positive?
      instructions
    end
  end

  class File
    extend T::Sig

    sig { returns(Integer) }
    attr_reader :size

    sig { returns(String) }
    attr_reader :name

    sig { params(name: String, size: Integer).void }
    def initialize(name, size)
      @name = T.let(name, String)
      @size = T.let(size, Integer)
    end

    sig { returns(String) }
    def to_s
      "- #{name} #{size}"
    end
  end

  class Directory
    extend T::Sig

    sig { returns(String) }
    attr_reader :name

    sig { returns(T.nilable(Directory)) }
    attr_reader :parent

    sig { params(name: String, parent: T.nilable(Directory)).void }
    def initialize(name, parent)
      @name = T.let(name, String)
      @parent = T.let(parent, T.nilable(Directory))
      @children = T.let({}, T::Hash[String, T.any(File, Directory)])
    end

    sig { returns(Integer) }
    def size
      @children.values.sum(&:size)
    end

    sig { params(name: String, size: Integer).returns(File) }
    def new_file(name, size)
      @children[name] = File.new(name, size)
    end

    sig { params(name: String).returns(Directory) }
    def new_directory(name)
      @children[name] = Directory.new(name, self)
    end

    sig { params(name: String).returns(T.nilable(T.any(File, Directory))) }
    def child(name)
      @children[name]
    end

    sig { returns(T::Array[T.any(Directory, File)]) }
    def children
      @children.values
    end

    sig { returns(String) }
    def to_s
      children = @children.values.map do |child|
        lines = child.to_s.split("\n")
        lines.map { |line| "  #{line}" }
      end.flatten.join("\n")

      "- #{name}: \n" + children
    end
  end

  class Instruction
    extend T::Sig
    extend T::Helpers
    abstract!

    sig { abstract.params(file_tree: FileTree).void }
    def execute(file_tree); end
  end

  class ChangeDirectory < Instruction
    extend T::Sig

    sig { params(input: String).void }
    def initialize(input)
      super()
      @input = T.let(input, String)
    end

    sig { override.params(file_tree: FileTree).void }
    def execute(file_tree)
      case @input
      when '/'
        file_tree.return_to_root
      when '..'
        file_tree.move_up
      else
        file_tree.move_down(@input)
      end
    end
  end

  class List < Instruction
    extend T::Sig

    sig { params(output: T::Array[String]).void }
    def initialize(output)
      super()
      @output = T.let(output, T::Array[String])
    end

    sig { override.params(file_tree: FileTree).void }
    def execute(file_tree)
      @output.each do |line|
        first, second = line.split
        if first == 'dir'
          dir_name = T.must(second)
          file_tree.current_dir.new_directory(dir_name)
        else
          size = T.must(first).to_i
          file_name = T.must(second)
          file_tree.current_dir.new_file(file_name, size)
        end
      end
    end
  end

  class FileTree
    extend T::Sig

    TOTAL_SPACE = T.let(70_000_000, Integer)

    sig { returns(Directory) }
    attr_reader :current_dir

    sig { void }
    def initialize
      @root = T.let(Directory.new('/', nil), Directory)
      @current_dir = T.let(@root, Directory)
    end

    sig { void }
    def return_to_root
      @current_dir = @root
    end

    sig { void }
    def move_up
      parent = @current_dir.parent
      @current_dir = parent unless parent.nil?
    end

    sig { params(name: String).void }
    def move_down(name)
      child = @current_dir.child(name)
      raise "#{name} is a file, not a directory" if child.is_a?(File)

      child = @current_dir.new_directory(name) if child.nil?
      @current_dir = child
    end

    sig { returns(String) }
    def to_s
      @root.to_s
    end

    sig { params(size: Integer).returns(T::Array[Directory]) }
    def directories_less_than(size)
      directories.filter { |d| d.size <= size }
    end

    sig { params(size: Integer).returns(T::Array[Directory]) }
    def directories_greater_than(size)
      directories.filter { |d| d.size >= size }
    end

    sig { returns(Integer) }
    def unused_space
      TOTAL_SPACE - @root.size
    end

    private

    sig { returns(T::Array[Directory]) }
    def directories
      directories = []
      queue = T.let([@root], T::Array[Directory])

      while queue.length.positive?
        dir = T.must(queue.pop)

        directories << dir

        dir.children.each do |child|
          queue << child if child.is_a?(Directory)
        end
      end

      directories
    end
  end

  class CommandName < T::Enum
    extend T::Sig

    enums do
      ChangeDirectory = new('cd')
      List = new('ls')
    end
  end

  class InstructionFactory
    class << self
      extend T::Sig

      sig { params(input: T::Array[String]).returns(Instruction) }
      def build_instruction(input)
        first_line = T.must(input.first)
        parts = first_line.split
        raise 'Invalid instruction, does not begin with $' if parts.first != '$'

        command_name = CommandName.deserialize(T.must(parts[1]))

        case command_name
        when CommandName::ChangeDirectory then build_cd(input)
        when CommandName::List then build_ls(input)
        else T.absurd(command_name)
        end
      end

      private

      sig { params(input: T::Array[String]).returns(Instruction) }
      def build_cd(input)
        raise 'cd command input should be of length 1' if input.length > 1

        parts = T.must(input.first).split
        dir_name = T.must(parts[2])
        ChangeDirectory.new(dir_name)
      end

      sig { params(input: T::Array[String]).returns(Instruction) }
      def build_ls(input)
        raise 'ls command input length should be > 1' if input.length == 1

        List.new(T.must(input[1..]))
      end
    end
  end
end
