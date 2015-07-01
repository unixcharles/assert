require 'assert/version'
require 'unparser'
require 'parser'
require 'pry'

module Assert
  def assert!(message = nil, &block)
    assertion_matcher = AssertionMatcher.new(block)
    assertion_type, arguments = catch(:assertion_arguments) do
      assertion_matcher.extract!
    end

    if assertion_type == :assert
      assert(block.call)
    else
      arguments = block.binding.eval("[#{arguments}]")
      send(assertion_type, *arguments)
    end
  end

  class AssertionMatcher
    attr_reader :block, :left, :expression, :right

    def initialize(block)
      @block = block
      block_content = unwrap_ast(
        Parser::CurrentRuby.parse(block.source)
      )

      @left, @expression, @right = extract_assertion(block_content)
    end

    def extract!
      catch(:assertion_arguments) do
        [ assertion_type, assertion_arguments ]
      end
    end

    private

    ASSERTION_MAP = {
      :< => :assert_operator,
      :> => :assert_operator,
      :<= => :assert_operator,
      :>= => :assert_operator,
      :== => :assert_equal,
      :'!=' => :refute_equal,
      :include? => :assert_includes,
      :empty? => :assert_empty,
      :instance_of? => :assert_instance_of,
      :kind_of? => :assert_kind_of,
      :=~ => :asset_match,
      :nil? => :assert_nil,
      :respond_to? => :assert_respond_to,
    }

    def assertion_type
      ASSERTION_MAP.fetch(expression) { throw(:assertion_arguments, [:assert, nil]) }
    end

    def assertion_arguments
      nodes = case assertion_type
      when :assert_includes, :assert_respond_to, :assert_equal, :refute_equal
        [*right, *left]
      when :assert_instance_of, :assert_kind_of, :asset_match, :assert_includes
        [*left, *right]
      when :assert_empty, :assert_nil
        right
      when :assert_operator
        [*right, expression, *left]
      else
        raise 'not implemented'
      end

      nodes_to_arguments(nodes)
    end

    def nodes_to_arguments(nodes)
      nodes.map do |node|
        case node
        when Parser::AST::Node then "( #{Unparser.unparse(node)} )"
        else node.inspect
        end
      end.join(', ')
    end

    def unwrap_ast(ast)
      _, _, block_content = ast.children
      block_content
    end

    SUPPORTED_METHODS = ASSERTION_MAP.keys

    def extract_assertion(ast)
      left, expression, right = [[], nil, []]

      if ast.children.any?
        children = Array.new(ast.children)

        while expression.nil?
          node = children.pop
          if SUPPORTED_METHODS.include?(node)
            expression = node
          else
            left << node
          end

          break if children.empty?
        end

        right = children
      else
        left = [ast]
      end

      [left, expression, right]
    end
  end
end
