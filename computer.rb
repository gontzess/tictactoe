## Computer Class

require_relative "tttplayer"

class Computer < TTTPlayer
  def initialize(name, board, opponent_marker, difficulty)
    @opponent_marker = opponent_marker
    @difficulty = difficulty
    super(name, board)
    set_plies
  end

  def calculate_move
    case @difficulty
    when :competitive then find_competitive_move
    when :minimax     then find_minimax_move
    when :negamax     then find_negamax_move
    end
  end

  private

  INFINITY = Float::INFINITY

  def set_marker
    @marker = "O"
  end

  def set_plies
    @plies = case @board.board_size ## set recommended max plies
             when 3 then 10
             when 5 then 10
             else        3
             end
  end

  def find_wins_threats(depth=1)
    wins = board.at_risk_squares(@marker, depth)
    threats = board.at_risk_squares(@opponent_marker, depth)
    return wins, threats
  end

  def move_for_oversized
    look_ahead_wins, look_ahead_threats = find_wins_threats(2)
    return look_ahead_wins.first      if look_ahead_wins
    return look_ahead_threats.first   if look_ahead_threats
    nil
  end

  def find_competitive_move
    immediate_wins, immediate_threats = find_wins_threats

    return immediate_wins.first     if immediate_wins
    return immediate_threats.first  if immediate_threats
    return board.center_key         if board.center_square.unmarked?
    return move_for_oversized       if board.oversized? && move_for_oversized

    board.unmarked_keys.sample
  end

  # rubocop:disable Metrics/MethodLength
  def minimax(square_key, brd, depth, side=1)
    brd_copy = brd.copy
    maximizing_player = side.positive?
    brd_copy[square_key] = maximizing_player ? @marker : @opponent_marker

    terminal_node, value = brd_copy.terminal_node(@marker, @opponent_marker)
    return depth * value if terminal_node || depth == 0

    value = maximizing_player ? -INFINITY : INFINITY

    brd_copy.unmarked_keys.each do |key|
      value = [value, minimax(key, brd_copy, (depth - 1), -side)]
      value = maximizing_player ? value.max : value.min
    end

    value
  end
  # rubocop:enable Metrics/MethodLength

  def find_minimax_move(brd=@board, depth=@plies, side=1)
    empty_keys = brd.unmarked_keys
    return brd.center_key if brd.center_square.unmarked?
    return find_competitive_move if empty_keys.length > 9

    weights = empty_keys.each_with_object({}) do |key, hash|
      hash[key] = minimax(key, brd, depth, side)
    end
    max_weight = weights.values.max
    max_keys = weights.select { |_, val| val == max_weight }.keys

    return max_keys.first if max_keys.length == 1

    max_keys.sample
  end

  def negamax(square_key, brd, depth, side=1)
    brd_copy = brd.copy
    marker = side.positive? ? @marker : @opponent_marker
    brd_copy[square_key] = marker

    terminal_node, value = brd_copy.terminal_node(@marker, @opponent_marker)
    return side * depth * value if terminal_node || depth == 0

    value = -INFINITY

    brd_copy.unmarked_keys.each do |key|
      value = [value, -negamax(key, brd_copy, (depth - 1), -side)].max
    end
    value
  end

  def find_negamax_move(brd=@board, depth=@plies, side=1)
    empty_keys = brd.unmarked_keys
    return brd.center_key if brd.center_square.unmarked?
    return find_competitive_move if empty_keys.length > 9

    weights = empty_keys.each_with_object({}) do |key, hash|
      hash[key] = negamax(key, brd, depth, side)
    end
    max_weight = weights.values.max
    max_keys = weights.select { |_, val| val == max_weight }.keys

    return max_keys.first if max_keys.length == 1

    max_keys.sample
  end
end
