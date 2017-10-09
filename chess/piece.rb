require_relative 'board'
require 'byebug'

class Piece
  attr_reader :symbol, :color
  attr_accessor :board, :pos

  DIAG = [[1, 1], [1, -1], [-1, -1], [-1, 1]]
  HORI = [[0, 1], [0, -1], [1, 0], [-1, 0]]

  def initialize(pos, color)
    @symbol = " p "
    @color = color
    @board = nil
    @pos = pos
  end

  def inspect
    symbol.to_s
  end

  def moves(board)
  end

  def pos_is_nullpiece?(pos)
    board[pos].is_a?(NullPiece)
  end

  def find_new_pos(pos, delta)
    [pos[0] + delta[0], pos[1] + delta[1]]
  end

  def pos_not_on_board(pos)
    !board.in_bounds?(pos)
  end

  def find_same_color(pos)
     board[pos].color == self.color
  end

  def find_enemy_color(pos)
    enemy_color = self.color == :black ? :red : :black
    board[pos].color == enemy_color
  end

  def valid_moves(board)
    final = []
    self.moves(board).each do |end_pos|
      new_board = board.dup
      new_board.move_piece!(self.pos, end_pos)
      final << end_pos unless new_board.in_check?(self.color)
    end
    final
  end

  def dup
    self.class.new(self.pos, self.color)
  end

end

module SlidingPiece

  def moves(board)
    self.board = board
    valid_moves = []
    move_dirs.each do |delta|
      temp_pos = find_new_pos(pos, delta)
      until pos_not_on_board(temp_pos) || find_same_color(temp_pos)
        if pos_is_nullpiece?(temp_pos)
          valid_moves << temp_pos
        elsif find_enemy_color(temp_pos)
          valid_moves << temp_pos
          break
        end
        temp_pos = find_new_pos(temp_pos, delta)
      end
    end
    valid_moves
  end

end


module SteppingPiece

  def moves(board)
    self.board = board
    valid_moves = []
    move_dirs.each do |delta|
      temp_pos = find_new_pos(pos, delta)
      unless pos_not_on_board(temp_pos) || find_same_color(temp_pos)
        if pos_is_nullpiece?(temp_pos)
          valid_moves << temp_pos
        elsif find_enemy_color(temp_pos)  
          valid_moves << temp_pos
        end
        temp_pos = find_new_pos(temp_pos, delta)
      end
    end
    valid_moves
  end

end

class Bishop < Piece
  include SlidingPiece
  attr_reader :move_dirs

  def initialize(pos, color)
    super
    @symbol = (color == :black) ? " \u265D " : " \u2657 "
    @move_dirs = DIAG
  end
end

class Rook < Piece
  include SlidingPiece
  attr_reader :move_dirs

  def initialize(pos, color)
    super
    @symbol = (color == :black) ? " \u265C " : " \u2656 "
    @move_dirs = HORI
  end
end

class Queen < Piece
  include SlidingPiece
  attr_reader :move_dirs

  def initialize(pos, color)
    super
    @symbol = (color == :black) ? " \u265B " : " \u2655 "
    @move_dirs = DIAG + HORI
  end

end

class Knight < Piece
  include SteppingPiece

  attr_reader :move_dirs
  def initialize(pos, color)
    super
    @symbol = color == :black ? " \u265E " : " \u2658 "
    @move_dirs = [[2, 1], [2, -1], [-2, -1], [-2, 1], [1, 2], [1, -2], [-1, -2], [-1, 2]]
  end

end

class King < Piece
  include SteppingPiece

  attr_reader :move_dirs
  def initialize(pos, color)
    super
    @symbol = (color == :black) ? " \u265A " : " \u2654 "
    @move_dirs = HORI + DIAG
  end

end

class Pawn < King
  attr_reader :attack_dirs, :move_dirs

  def initialize(pos, color)
    super
    @symbol = (color == :black) ? " \u265F " : " \u2659 "
    @move_dirs = (color == :black) ? [[1, 0]] : [[-1, 0]]
    @attack_dirs = (color == :black) ? [[1, 1], [1, -1]] : [[-1, -1], [-1, 1]]
  end



  def moves(board)
    self.board = board
    valid_dirs = []

    attack_dirs.each do |delta|
      temp_pos = find_new_pos(pos, delta)
      if board.in_bounds?(temp_pos)
        valid_dirs << temp_pos if find_enemy_color(temp_pos)
      end
    end

    move_dirs.each do |delta|
      temp_pos = find_new_pos(pos, delta)
      if board.in_bounds?(temp_pos) && pos_is_nullpiece?(temp_pos)
        valid_dirs << temp_pos
      end
      if at_starting_row? && pos_is_nullpiece?(temp_pos)
        temp_pos = find_new_pos(temp_pos, delta)
        if board.in_bounds?(temp_pos) && pos_is_nullpiece?(temp_pos)
          valid_dirs << temp_pos
        end
      end
    end
    valid_dirs
  end

  def at_starting_row?
    return true if color == :black && pos.first == 1
    return true if color == :red && pos.first == 6
    false
  end

end



require 'singleton'

class NullPiece < Piece

  include Singleton

  def initialize
    @symbol = "   "
  end

  def inspect
    "   "
  end

  def pos=(val)
  end
end
