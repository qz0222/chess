class ChessError < StandardError
end

class NoPieceError < ChessError
end

class InvalidMoveError < ChessError
end

class MoveIntoCheckError < ChessError
end

class WrongColorSelectedError < ChessError
end
