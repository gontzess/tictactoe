CREATE TYPE difficulty_type AS ENUM ('competitive', 'minimax', 'negamax');

CREATE TABLE leaderboard (
  id serial PRIMARY KEY,
  human_name text NOT NULL,
  human_wins integer NOT NULL,
  computer_wins integer NOT NULL,
  rounds_played integer NOT NULL,
  board_size integer NOT NULL CHECK (board_size BETWEEN 3 AND 7),
  difficulty difficulty_type NOT NULL,
  time_stamp timestamp NOT NULL DEFAULT (current_timestamp)
);
