require 'test/unit'
require 'rack/router'

class RouterTest < Test::Unit::TestCase
  def test_call
    app1  = lambda{|env| [200, {}, [env["rack.route_params"][:id]]] }
    app2  = lambda{|env| [200, {}, ["2"]] }

    router = Rack::Router.new do
      post "/stuff" => app2, :as => "stuff"
      put "/it" => app2, :as => :it
      delete "/remove" => app2
      get "/:id" => app1
    end

    assert_equal({
      "POST" => [Rack::Route.new("/stuff", app2)],
      "PUT" => [Rack::Route.new("/it", app2)],
      "DELETE" => [Rack::Route.new("/remove", app2)],
      "GET"  => [Rack::Route.new("/:id", app1)]
    }, router.routes)

    assert_equal ["42"], router.call("REQUEST_METHOD" => "GET", "PATH_INFO" => "/42").last
    assert_equal "/stuff", router[:stuff]
    assert_equal "/it", router[:it]
  end
end

