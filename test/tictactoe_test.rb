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
end
