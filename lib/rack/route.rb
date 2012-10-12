module Rack
  class Route

    attr_accessor :pattern, :app, :constraints

    PATH_INFO = 'PATH_INFO'.freeze
    DEFAULT_WILDCARD_NAME = :paths
    WILDCARD_PATTERN = /\/\*(.*)/.freeze
    NAMED_SEGMENTS_PATTERN = /\/:([^$\/]+)/.freeze
    NAMED_SEGMENTS_REPLACEMENT_PATTERN = /\/:([^$\/]+)/.freeze
    DOT = '.'.freeze

    def initialize(pattern, app, constraints=nil)
      if pattern.to_s.strip.empty?
        raise ArgumentError.new("pattern cannot be blank")
      end

      unless app.respond_to?(:call)
        raise ArgumentError.new("app must be callable")
      end

      @pattern = pattern
      @app = app
      @constraints = constraints
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
      elsif pattern_match = pattern.match(NAMED_SEGMENTS_PATTERN)
        pattern.gsub(NAMED_SEGMENTS_REPLACEMENT_PATTERN, '/(?<\1>[^$/]+)')
      else
        pattern
      end
      Regexp.new("\\A#{src}\\Z")
    end

    def match(path)
      if path.to_s.strip.empty?
        raise ArgumentError.new("path is required")
      end

      if path_match = path.split(DOT).first.match(regexp)
        params = if @wildcard_name
          { @wildcard_name => path_match[1].to_s.split('/') }
        else
          Hash[path_match.names.map(&:to_sym).zip(path_match.captures)]
        end

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
        o.pattern == pattern &&
        o.app == app &&
        o.constraints == constraints
    end
    alias == eql?

    def hash
      pattern.hash ^ app.hash ^ constraints.hash
    end
  end
end
