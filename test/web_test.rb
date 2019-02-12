require "test_helper"

require File.expand_path("../web", __dir__)

class WebTest < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_root
    get '/'
    assert last_response.ok?
  end

  def test_start
    post '/start'
    assert last_response.ok?
    assert_equal %q({"color":"#fff000"}), last_response.body
  end

  def test_end
    post '/end'
    assert last_response.ok?
    assert_equal %q({}), last_response.body
  end

  def test_ping
    post '/start'
    assert last_response.ok?
  end
end
