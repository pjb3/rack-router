require 'rack/route'
require 'rack/version'

module Rack

  class Router

    HEAD = 'HEAD'.freeze
    GET = 'GET'.freeze
    POST = 'POST'.freeze
    PUT = 'PUT'.freeze
    DELETE = 'DELETE'.freeze
    REQUEST_METHOD = 'REQUEST_METHOD'.freeze
    PATH_INFO = 'PATH_INFO'.freeze
    ROUTE_PARAMS = 'rack.route_params'.freeze

    def initialize(&block)
      @routes = {}
      @named_routes = {}
      routes(&block)
    end

    def [](route_name)
      @named_routes[route_name]
    end

    def routes(&block)
      instance_eval(&block) if block
      @routes
    end

    def get(route_spec)
      route(GET, route_spec)
    end

    def post(route_spec)
      route(POST, route_spec)
    end

    def put(route_spec)
      route(PUT, route_spec)
    end

    def delete(route_spec)
      route(DELETE, route_spec)
    end

    def route(method, route_spec)
      route = Route.new(route_spec.first.first, route_spec.first.last, route_spec.reject{|k,_| k == route_spec.first.first })
      @routes[method] ||= []
      @routes[method] << route
      if route_spec && route_spec[:as]
        # Using ||= so the first route with that name will be returned
        @named_routes[route_spec[:as].to_sym] ||= route_spec.first.first
      end
      route
    end

    def call(env)
      if app = match(env)
        app.call(env)
      else
        not_found(env)
      end
    end

    def match(env)
      request_method = env[REQUEST_METHOD]
      request_method = GET if request_method == HEAD
      if method_routes = @routes[request_method]
        method_routes.each do |route|
          if params = route.match(env[PATH_INFO])
            env[ROUTE_PARAMS] = params
            return route.app
          end
        end
        nil
      end
    end

    def not_found(env)
      body = "<h1>Not Found</h1><p>No route matches #{env[REQUEST_METHOD]} #{env[PATH_INFO]}</p>"
      [
        404,
        {
          "Content-Type" => "text/html",
          "Content-Length" => body.length.to_s
        },
        [body]
      ]
    end
  end
end

