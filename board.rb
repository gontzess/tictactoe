## Board Class

require_relative "square"

class Board
  attr_reader :board_size, :center_key

  def initialize(board_size)
    @board_size = board_size
    @num_of_squares = board_size**2
    @center_key = (board_size**2 + 1) / 2
    @squares = {}
    reset_squares
    reset_winning_lines
  end

  def reset_squares
    (1..@num_of_squares).each { |key| @squares[key] = Square.new }
  end

  def reset_winning_lines
    rows = winning_rows
    columns = winning_columns
    diagonals = winning_diagonals(rows, columns)
    @winning_lines = rows + columns + diagonals
  end

  def each_square
    @squares.each { |key, square| yield(key, square) }
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def copy
    brd_clone = Board.new(board_size)
    (1..@num_of_squares).each do |key|
      brd_clone[key] = @squares[key].marker
    end
    brd_clone
  end

  def unmarked_keys
    @squares.keys.select { |num| @squares[num].unmarked? }
  end

  def center_square
    @squares[@center_key]
  end

  def oversized?
    @board_size > 3
  end

  def at_risk_squares(player_marker, depth=1)
    at_risk = find_at_risk_squares(player_marker, depth)

    return nil if at_risk.empty?

    at_risk.sort_by { |key| at_risk.count(key) }.reverse.uniq
  end

  def terminal_node(marker, opponent_marker)
    certain_win = winning_marker == marker
    certain_tie = draw_round?
    certain_loss = winning_marker == opponent_marker


    if certain_win     then 100
    elsif certain_tie  then 0
    elsif certain_loss then -100
    else                    nil
    end
  end

  def winning_marker
    @winning_lines.each do |line|
      squares, markers = content_from(line)
      if markers.uniq.size == 1 && squares.all?(&:marked?)
        return markers.first
      end
    end
    nil
  end

  def someone_won_round?
    !!winning_marker
  end

  def draw_round?
    @winning_lines.reject { |line| unwinnable?(line) }.empty?
  end

  def empty?
    @squares.values.all?(&:unmarked?)
  end

  private

  def winning_rows
    winning_rows = []
    (1..@num_of_squares).step(board_size) do |x|
      row = []
      (0..board_size - 1).each do |y|
        row << x + y
      end
      winning_rows << row
    end
    winning_rows
  end

  def winning_columns
    winning_columns = []
    (1..board_size).each do |x|
      column = []
      (x..@num_of_squares).step(board_size) do |y|
        column << y
      end
      winning_columns << column
    end
    winning_columns
  end

  def winning_diagonals(winning_rows, winning_columns)
    diagonal1 = []
    diagonal2 = []
    (0..board_size - 1).each do |idx|
      other_idx = (board_size - 1) - idx
      diagonal1 << winning_rows[idx][idx]
      diagonal2 << winning_columns[other_idx][idx]
    end
    [diagonal1, diagonal2]
  end

  def content_from(line)
    squares = @squares.values_at(*line)
    markers = squares.map(&:marker)
    return squares, markers
  end

  def line_almost_full?(line, player_marker, depth)
    squares, markers = content_from(line)
    markers.count(player_marker) == board_size - depth &&
      squares.select(&:unmarked?).size == depth
  end

  def unwinnable?(line)
    squares, markers = content_from(line)
    markers_count = markers.uniq.size
    markers_count == 3 || (markers_count == 2 && squares.all?(&:marked?))
  end

  def find_at_risk_squares(player_marker, depth=1)
    at_risk = []
    depth = 1 if !oversized? ## if 3x3 board, ensure depth always 1
    @winning_lines.each do |line|
      if line_almost_full?(line, player_marker, depth)
        line.each { |key| at_risk << key if @squares[key].unmarked? }
      end
    end

    at_risk
  end
end
