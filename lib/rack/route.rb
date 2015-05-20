module Rack
  class Route
    attr_accessor :request_method, :pattern, :app, :constraints, :name

    PATH_INFO = 'PATH_INFO'.freeze
    DEFAULT_WILDCARD_NAME = :paths
    WILDCARD_PATTERN = /\/\*(.*)/.freeze
    NAMED_SEGMENTS_PATTERN = /\/([^\/]*):([^:$\/]+)/.freeze
    DOT = '.'.freeze

    def initialize(request_method, pattern, app, options={})
      if pattern.to_s.strip.empty?
        raise ArgumentError.new("pattern cannot be blank")
      end

      unless app.respond_to?(:call)
        raise ArgumentError.new("app must be callable")
      end

      @request_method = request_method
      @pattern = pattern
      @app = app
      @constraints = options && options[:constraints]
      @name = options && options[:as]
    end

    def regexp
      @regexp ||= compile
    end

    def compile
      src = if pattern_match = pattern.match(WILDCARD_PATTERN)
        @wildcard_name = if pattern_match[1].to_s.strip.empty?
          DEFAULT_WILDCARD_NAME
        else
          pattern_match[1].to_sym
        end
        pattern.gsub(WILDCARD_PATTERN,'(?:/(.*)|)')
      else
        p = if pattern_match = pattern.match(NAMED_SEGMENTS_PATTERN)
          pattern.gsub(NAMED_SEGMENTS_PATTERN, '/\1(?<\2>[^.$/]+)')
        else
          pattern
        end
        p + '(?:\.(?<format>.*))?'
      end
      #puts "pattern: #{pattern}, src: #{src}"
      Regexp.new("\\A#{src}\\Z")
    end

    def match(request_method, path)
      unless request_method == self.request_method
        return nil
      end

      if path.to_s.strip.empty?
        raise ArgumentError.new("path is required")
      end

      if path_match = path.match(regexp)
        params = if @wildcard_name
          { @wildcard_name => path_match[1].to_s.split('/') }
        else
          Hash[path_match.names.map(&:to_sym).zip(path_match.captures)]
        end

        params.delete(:format) if params.has_key?(:format) && params[:format].nil?

        if meets_constraints(params)
          params
        end
      end
    end

    def meets_constraints(params)
      if constraints
        constraints.each do |param, constraint|
          unless params[param].to_s.match(constraint)
            return false
          end
        end
      end
      true
    end

    def eql?(o)
      o.is_a?(self.class) &&
        o.request_method == request_method &&
        o.pattern == pattern &&
        o.app == app &&
        o.constraints == constraints
    end
    alias == eql?

    def hash
      request_method.hash ^ pattern.hash ^ app.hash ^ constraints.hash
    end
  end
end
