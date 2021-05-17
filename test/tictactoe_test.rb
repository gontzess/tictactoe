ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "../tictactoe"

class TTTTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
  end

  def teardown
  end

  def session
    last_request.env["rack.session"]
  end

  def test_new_game_page
    get "/"
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_equal 200, last_response.status
    assert_includes last_response.body, "<input"
    assert_includes last_response.body, %q(<button type="submit")
  end

  def test_new_game_submit
    get "/new"
    assert_nil session[:game]
    assert_nil session[:message]

    post "/new", { human_name: "tester", rounds: "3", board_size: "3",
      difficulty: "minimax" }
    assert_equal 302, last_response.status
    assert_equal true, session[:game].is_a?(TTTGame)
    assert_includes session[:message], "tester, welcome to Tic Tac Toe!"

    get last_response["Location"]
    assert_equal 200, last_response.status
    empty_squares = 0
    session[:game].board.each_square do |_, sq|
      empty_squares += 1 if sq.unmarked?
    end
    assert_equal 9, empty_squares
    assert_includes last_response.body, "tester: 0, Bot: 0."
  end

  def test_user_first_move_submit
    post "/new", { human_name: "tester", rounds: "3", board_size: "3",
      difficulty: "minimax" }
    assert_equal 302, last_response.status

    get last_response["Location"]
    assert_equal 200, last_response.status

    post "/play", { key: "3"}
    assert_equal 302, last_response.status
    assert_includes session[:message], "tester chose 3."

    get last_response["Location"]
    assert_equal 200, last_response.status
    refute_includes last_response.body, %q(value="3"></button>)
    refute_includes last_response.body, %q(value="5"></button>) ## comp move
  end
end
