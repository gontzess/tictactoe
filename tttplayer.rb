## TTTPlayer Class

class TTTPlayer
  attr_reader :wins, :name, :marker

  def initialize(name, board)
    @name = name
    @board = board
    @wins = 0
    set_marker
  end

  def won_round
    @wins += 1
  end

  def won_game?(max)
    @wins >= max
  end

  private

  attr_reader :board
end
