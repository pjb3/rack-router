require 'rack/router'
require 'rack/lobster'

router = Rack::Router.new do
  get "/hello/:name" => proc{|env| [200, { "Content-Type" => "text/html" }, ["<h1>Hello, #{env['rack.route_params'][:name]}</h1>"] ] }
  get "/lobster" => Rack::Lobster.new
end

run router
