require_relative 'display'
require_relative 'HumanPlayer'

class Game

  attr_accessor :current_player
  attr_reader :board, :disp, :player1, :player2

  def initialize(player1, player2)
    @board = Board.new
    @player1 = player1
    @player2 = player2
    @current_player = player1
    @disp = Display.new(board, current_player)
  end

  def play
    until game_over?
      begin
        disp.render
        current_player.board = board
        start_input = nil
        until start_input
          disp.render
          start_input = disp.cursor.get_input
        end
        raise WrongColorSelectedError if board[start_input].color != current_player.color
        end_input = nil
        until end_input
          disp.render
          end_input = disp.cursor.get_input
        end
        self.board.move_piece(start_input, end_input)
      rescue ChessError => e
        puts e.message
        puts "Lets try something else!"
        sleep(1)
        retry
      end
      switch_player
      self.disp.current_player = current_player
    end
    disp.render
    puts "Checkmate! Game over!"

  end

  def switch_player
    self.current_player = self.current_player == player1 ? player2 : player1
  end

  def game_over?
    board.checkmate?(current_player.color)
  end

end


if __FILE__ == $PROGRAM_NAME
  p1 = HumanPlayer.new("Tom", :black)
  p2 = HumanPlayer.new("Mary", :red)
  game = Game.new(p1, p2)
  game.play
end
