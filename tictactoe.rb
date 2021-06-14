## Tic Tac Toe

require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

require_relative "tttgame"
require_relative "database_storage"

configure do
  enable :sessions
  set :session_secret, "secret" ## normally wouldn't store env variable in code
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "database_storage.rb"
end

helpers do
  def divider
    %q(<div class="divider"></div>)
  end

  def row_of_dividers
    divider * (@game.board.board_size * 2 - 1)
  end
end

before do
  @storage = DatabaseStorage.new
end

after do
  @storage.disconnect
end

get "/" do
  redirect "/new"
end

get "/new" do
  erb :new
end

post "/new" do
  name = params[:human_name].to_s
  rounds = params[:rounds].to_i
  board_size = params[:board_size].to_i
  difficulty = params[:difficulty].to_sym
  game = TTTGame.new(name, "Bot", rounds, board_size, difficulty)
  session[:game] = game
  session[:message] = game.display_welcome_rules_message
  redirect "/play"
end

get "/play" do
  @game = session[:game]
  redirect "/new" if @game.nil? || @game.over?
  @board_size = @game.board.board_size

  @game.reset if params[:next_round]

  if @game.board.someone_won_round? || @game.board.draw_round?
    session.delete(:message)
    session[:results] = @game.round_results
    session[:results] = @game.game_results if @game.over?
    redirect "/summary"
  end

  if @game.computers_turn?
    choice = @game.computer_moves
    session[:message] = "#{@game.computer.name} chose #{choice}."
  end

  if @game.board.someone_won_round? || @game.board.draw_round?
    session[:results] = @game.round_results
    session[:results] = @game.game_results if @game.over?
    redirect "/summary"
  end

  erb :play
end

post "/play" do
  game = session[:game]
  choice = params[:key].to_i

  if game.humans_turn?
    game.human_moves(choice)
    session[:message] = "#{game.human.name} chose #{choice}."
  end

  redirect "/play"
end

get "/summary" do
  @game = session[:game]
  redirect "/new" unless @game
  @board_size = @game.board.board_size

  @storage.add_to_leaderboard(@game) if @game.over?

  erb :summary
end

get "/leaderboard" do
  @leaderboard = @storage.all_leaderboard_results

  erb :leaderboard
end
