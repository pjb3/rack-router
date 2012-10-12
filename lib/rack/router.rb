require 'rack/route'

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
    DEFAULT_NOT_FOUND_BODY = '<h1>Not Found</h1>'.freeze
    DEFAULT_NOT_FOUND_RESPONSE = [404,
      {
        "Content-Type" => "text/html",
        "Content-Length" => DEFAULT_NOT_FOUND_BODY.length.to_s
      }, [DEFAULT_NOT_FOUND_BODY]]

    def initialize(&block)
      @routes = {}
      routes(&block)
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
      route = Route.new(route_spec.first.first, route_spec.first.last)
      @routes[method] ||= []
      @routes[method] << route
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
      end
    end

    def not_found(env)
      DEFAULT_NOT_FOUND_RESPONSE
    end
  end
end

