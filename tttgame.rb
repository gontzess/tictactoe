## TTTGame Class

require_relative "board"
require_relative "human"
require_relative "computer"

class TTTGame
  attr_reader :board, :human, :computer, :round

  def initialize(player_name, computer_name, rounds, board_size, difficulty)
    @rounds_to_win = rounds
    @board = Board.new(board_size)
    @human = Human.new(player_name, @board)
    @computer = Computer.new(computer_name, @board, human.marker, difficulty)
    @round = 1
    set_first_move
  end

  def display_welcome_rules_message
    "#{human.name}, welcome to Tic Tac Toe!\n" \
      "You will be playing against #{computer.name}.\n" \
      "The first to #{@rounds_to_win} rounds wins all!"
  end

  def display_goodbye_message
    "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def humans_turn?
    @current_marker == human.marker
  end

  def computers_turn?
    @current_marker == computer.marker
  end

  def human_moves(choice)
    @board[choice] = human.marker
    @current_marker = computer.marker
    choice
  end

  def computer_moves
    choice = computer.calculate_move
    @board[choice] = computer.marker
    @current_marker = human.marker
    choice
  end

  def display_score
    "#{human.name}: #{human.wins}, #{computer.name}: #{computer.wins}."
  end

  def round_results
    case @board.winning_marker
    when human.marker
      @human.won_round
      "#{human.name} wins this round!"
    when computer.marker
      @computer.won_round
      "#{computer.name} wins this round!"
    else
      "It's a draw!"
    end
  end

  def reset
    @round += 1
    set_first_move
    @board.reset_squares
    @board.reset_winning_lines
  end

  def someone_won_game?
    human.won_game?(@rounds_to_win) || computer.won_game?(@rounds_to_win)
  end
  alias_method :over?, :someone_won_game?

  def game_results
    case human.wins <=> computer.wins
    when 1  then "#{human.name} won the game!"
    when -1 then "#{computer.name} won the game!"
    else         "Error, we tiredddd, we give up!"
    end
  end

  private

  def set_first_move
    @current_marker = @round.odd? ? human.marker : computer.marker
  end
end
