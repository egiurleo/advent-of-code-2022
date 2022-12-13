# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'
module Day12
  class << self
    extend T::Sig

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_one(input)
      starting_nodes, ending_node, _ = construct_graph(input)
      T.must(depth_first_search(T.must(starting_nodes.first), ending_node))
    end

    sig { params(input: T::Array[String]).returns(Integer) }
    def part_two(input)
      starting_nodes, ending_node, graph = construct_graph(input, multiple_starting_nodes: true)
      distances = T.let([], T::Array[Integer])

      starting_nodes.each do |starting_node|
        graph.each_value(&:unvisit)
        distance = depth_first_search(starting_node, ending_node)
        distances <<  distance if distance
      end

      T.must(distances.min)
    end

    private

    sig do
      params(input: T::Array[String], multiple_starting_nodes: T::Boolean)
      .returns([T::Array[Node], Node, T::Hash[[Integer, Integer], Node]])
    end
    def construct_graph(input, multiple_starting_nodes: false)
      nodes = T.let({}, T::Hash[[Integer, Integer], Node])

      starting_nodes = T.let([], T::Array[Node])
      ending_node = Node.new(-1, [-1, -1])

      input.each_with_index do |line, i|
        line.chars.each.with_index do |char, j|
          case char
          when 'S'
            node = Node.new('a'.ord, [i, j])
            starting_nodes << node
          when 'E'
            node = Node.new('z'.ord, [i, j])
            ending_node = node
          else
            node = Node.new(char.ord, [i, j])
            starting_nodes << node if char == 'a' && multiple_starting_nodes
          end

          nodes[[i, j]] = node
        end
      end

      nodes.each do |key, node|
        i, j = key

        [
          [i - 1, j],
          [i + 1, j],
          [i, j + 1],
          [i, j - 1]
        ].each do |ii, jj|
          other_node = nodes[[ii, jj]]
          next if other_node.nil?

          node.add_edge(other_node) if other_node.height <= node.height + 1
        end
      end

      [starting_nodes, ending_node, nodes]
    end

    sig { params(starting_node: Node, ending_node: Node).returns(T.nilable(Integer)) }
    def depth_first_search(starting_node, ending_node)
      queue = T.let([], T::Array[[Node, Integer]])
      queue << [starting_node, 0]

      distances = T.let([], T::Array[Integer])

      while queue.length.positive?
        curr_node, curr_distance = T.must(queue.shift)
        next if curr_node.visited?

        if curr_node == ending_node
          distances << curr_distance
          next
        end

        curr_node.edges.each do |edge|
          queue << [edge, curr_distance + 1]
        end

        curr_node.visit
      end

      distances.min
    end
  end

  class Node
    extend T::Sig

    sig { returns(Integer) }
    attr_reader :height

    sig { returns([Integer, Integer]) }
    attr_reader :coordinates

    sig { returns(T::Array[Node]) }
    attr_reader :edges

    sig { params(height: Integer, coordinates: [Integer, Integer]).void }
    def initialize(height, coordinates)
      @height = T.let(height, Integer)
      @visited = T.let(false, T::Boolean)
      @edges = T.let([], T::Array[Node])
      @coordinates = T.let(coordinates, [Integer, Integer])
    end

    sig { params(node: Node).void }
    def add_edge(node)
      @edges << node
    end

    sig { returns(String) }
    def to_s
      "Node #{coordinates} - #{@height.chr}"
    end

    sig { void }
    def visit
      @visited = true
    end

    sig { void }
    def unvisit
      @visited = false
    end

    sig { returns(T::Boolean) }
    def visited?
      @visited
    end
  end
end
