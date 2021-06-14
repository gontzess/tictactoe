require "pg"

class DatabaseStorage
  def initialize
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: "tictactoe")
          end
  end

  def disconnect
    @db.close
  end

  def add_to_leaderboard(game)
    sql = <<~SQL
      INSERT INTO leaderboard (human_name,
                              human_wins,
                              computer_wins,
                              rounds_played,
                              board_size,
                              difficulty)
      VALUES ($1, $2, $3, $4, $5, $6);
    SQL
    query(sql, game.human.name,
               game.human.wins,
               game.computer.wins,
               game.round,
               game.board.board_size,
               game.computer.difficulty.to_s)
  end

  def all_leaderboard_results
    sql = <<~SQL
      SELECT human_name, count(id) AS games_won, difficulty, board_size FROM leaderboard
      WHERE human_wins > computer_wins
      GROUP BY human_name, difficulty, board_size
      ORDER BY difficulty DESC, board_size DESC, games_won DESC;
    SQL
    results = query(sql)
    counter = 0
    results.map do |tuple, idx|
      counter += 1
      tuple_to_leaderboard_hash(tuple, counter)
    end
  end

  private

  def query(statement, *params)
    @db.exec_params(statement, params)
  end

  def tuple_to_leaderboard_hash(tuple, rank)
    { "Rank" => rank,
      "Name" => tuple["human_name"],
      "Difficulty" => tuple["difficulty"].gsub(/\Anegamax\z/, 'impossible'),
      "Board Size" => tuple["board_size"].to_i,
      "Games Won" => tuple["games_won"].to_i }
  end
end
