require "minitest/autorun"
require 'rack/router'

class RouterTest < Minitest::Test
  def test_call
    app1  = lambda{|env| [200, {}, [env["rack.route_params"][:id]]] }
    app2  = lambda{|env| [200, {}, ["2"]] }

    router = Rack::Router.new do
      post "/stuff" => app2, :as => "stuff"
      put "/it" => app2, :as => :it
      delete "/remove" => app2
      get "/:id" => app1
      patch "/patch" => app2
    end

    assert_equal([
      Rack::Route.new('POST', '/stuff', app2),
      Rack::Route.new('PUT', '/it', app2),
      Rack::Route.new('DELETE', '/remove', app2),
      Rack::Route.new('GET', '/:id', app1),
      Rack::Route.new('PATCH', '/patch', app2),
    ], router.routes)

    assert_equal ["42"], router.call("REQUEST_METHOD" => "GET", "PATH_INFO" => "/42").last
    assert_equal ["<h1>Not Found</h1><p>No route matches GET /not/found</p>"], router.call("REQUEST_METHOD" => "GET", "PATH_INFO" => "/not/found").last
    assert_equal "/stuff", router[:stuff]
    assert_equal "/it", router[:it]
  end
end
