require_relative 'cursor'
require_relative 'board'
require_relative 'display'

class HumanPlayer

  attr_accessor :board
  attr_reader :name, :cursor, :color

  def initialize(name, color)
    @name = name
    @board = Board.new
    @cursor = Cursor.new([0, 0], board)
    @color = color
  end

  def play_turn
    input = cursor.get_input
  end
end
