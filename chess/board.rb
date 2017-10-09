require_relative 'piece'
require_relative 'errors'
require 'byebug'

class Board

  attr_accessor :grid

  SETUP_HASH = {
    Rook => [[0, 0], [0, 7], [7, 0], [7, 7]],
    Bishop => [[0, 2], [0, 5], [7, 2], [7, 5]],
    Queen => [[0, 3], [7, 3]],
    King => [[0, 4], [7, 4]],
    Knight => [[0, 1], [0, 6], [7, 1], [7, 6]]
  }

  def initialize
    @grid = Array.new(8) { Array.new(8) }
    setup_pieces
  end

  def setup_pieces
    rows_to_change = [1, 6]
    rows_to_change.each do |i|
      color = (i == 1 ? :black : :red)
      grid[i].map!.with_index { |_, idx| Pawn.new([i, idx], color) }
    end

    SETUP_HASH.each do |key, val|
      val.each do |pos|
        color = (pos.first == 0 ? :black : :red)
        self[pos] = key.new(pos, color)
      end
    end

    rows_nil = [2, 3, 4, 5]
    rows_nil.each do |i|
      grid[i].map! { |z| NullPiece.instance }
    end
  end

  def move_piece(start_pos, end_pos)
    raise NoPieceError if self[start_pos].is_a?(NullPiece)
    raise InvalidMoveError unless self[start_pos].moves(self).include?(end_pos)
    raise MoveIntoCheckError unless self[start_pos].valid_moves(self).include?(end_pos)


    if self[end_pos].is_a?(NullPiece)
      self[start_pos].pos, self[end_pos].pos = end_pos, start_pos
      self[start_pos], self[end_pos] = self[end_pos], self[start_pos]
    else
      self[end_pos] = self[start_pos]
      self[start_pos] = NullPiece.instance
      self[end_pos].pos = end_pos
    end
  end

  def move_piece!(start_pos, end_pos)
    if self[end_pos].is_a?(NullPiece)
      self[start_pos].pos, self[end_pos].pos = end_pos, start_pos
      self[start_pos], self[end_pos] = self[end_pos], self[start_pos]
    else
      self[end_pos] = self[start_pos]
      self[start_pos] = NullPiece.instance
      self[end_pos].pos = end_pos
    end
  end

  def in_bounds?(pos)
    pos.all? do |i|
      i.between?(0, 7)
    end
  end

  def [](pos)
    x, y = pos
    self.grid[x][y]
  end

  def []=(pos, piece)

    x, y = pos
    self.grid[x][y] = piece
  end

  def in_check?(color)
    grid = self.grid.flatten

    king = grid.find do |piece|
      piece.class == King && piece.color == color
    end

    enemy_color = (color == :black ? :red : :black)
    grid.each do |piece|
      if piece.color == enemy_color
        return true if piece.moves(self).include?(king.pos)
      end
    end
    false
  end


  def checkmate?(color)
    if in_check?(color)
      return true if player_pieces(color).all? do |piece|
        piece.valid_moves(self).empty?
      end
    end
    false
  end

  def disp
    grid.each do |row|
      p row
    end
  end

  def player_pieces(color)
    self.grid.flatten.select do |piece|
      piece.color == color
    end
  end

  def dup
    dup_board = Board.new
    grid.each_with_index do |row, row_idx|
      row.each_with_index do |el, el_idx|
        if el.is_a?(NullPiece)
          dup_board[[row_idx, el_idx]] = NullPiece.instance
        else
          dup_board[[row_idx, el_idx]] = el.dup
        end
      end
    end
    dup_board
  end


end
