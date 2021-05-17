## Human Class

require_relative "tttplayer"

class Human < TTTPlayer
  private

  def set_marker
    @marker = "X"
  end
end
