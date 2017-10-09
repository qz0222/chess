require_relative 'board'
require_relative 'cursor'
require 'colorize'

class Display

  attr_reader :cursor, :board
  attr_accessor :current_player

  def initialize(board, current_player)
    @cursor = Cursor.new([0, 0], board)
    @board = board
    @current_player = current_player
  end

  def cursor_pos
    self.cursor.cursor_pos
  end

  def render
    system('clear')
    valid_moves = []
    valid_moves = board[cursor_pos].valid_moves(board) unless board[cursor_pos].is_a?(NullPiece)
    puts "   a  b  c  d  e  f  g  h "
    (0..7).each do |row|
      print "#{row + 1} "
      (0..7).each do |col|
        el = board[[row, col]]
        total = row + col
        if valid_moves.include?([row , col])
           print el.symbol.colorize( :color => el.color, :background => :light_yellow)

        elsif [row, col] == cursor_pos
          print el.symbol.colorize(:background => :light_green)
        else
          color = (total.even? ? :grey : :light_white)
          print el.symbol.colorize(:color => el.color, :background => color)
        end
      end
      puts ""
    end
    puts ""
    puts "It is #{current_player.name}'s turn. Your color is #{current_player.color}."
  end

end
