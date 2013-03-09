require 'rack/router'
require 'rack/lobster'

hello = ->(env) do
  [
    200,
    { "Content-Type" => "text/html" },
    ["<h1>Hello, #{env['rack.route_params'][:name]}</h1>"]
  ]
end

router = Rack::Router.new do
  get "/hello/:name" => hello
  get "/lobster" => Rack::Lobster.new, :as => "lobster"
end

run router
