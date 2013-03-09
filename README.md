# Rack::Router

A simple router for rack apps.  Requires Ruby 1.9+.

## Installation

Add this line to your application's Gemfile:

    gem 'rack-router'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-router

## Usage

Here's an example showing a simple rack app that prints the value of a route parameter:

``` ruby
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
```

In this example, `hello` is just a rack app defined inline, in order to give us something to route to.  The route to our hello app includes a parameter `:name`.  The hello rack app is able to access that parameter via the rack env.

This is a valid Rackup file, so if you put this in a file named `config.ru` and run `rackup`, you will be app to hit the application like this:

    $ curl http://localhost:9292/hello/paul
    <h1>Hello, paul</h1>

Don't forget to try the lobster!

    $ open http://localhost:9292/lobster

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
