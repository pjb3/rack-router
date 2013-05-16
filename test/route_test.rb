require "test/unit"
require "rack/route"

class RouteTest < Test::Unit::TestCase

  def test_match
    match "/*"         , "/"             , :paths => []
    match "/*"         , "/foo"          , :paths => %w[foo]
    match "/*"         , "/foo/bar/baz"  , :paths => %w[foo bar baz]
    match "/*stuff"    , "/"             , :stuff => []
    match "/*stuff"    , "/foo"          , :stuff => %w[foo]
    match "/*stuff"    , "/foo/bar/baz"  , :stuff => %w[foo bar baz]
    match "/foo/*"     , "/"             , nil
    match "/foo/*"     , "/foo"          , :paths => []
    match "/foo/*"     , "/foo/bar/baz"  , :paths => %w[bar baz]
    match "/foo/*stuff", "/"             , nil
    match "/foo/*stuff", "/foo"          , :stuff => []
    match "/foo/*stuff", "/foo/bar/baz"  , :stuff => %w[bar baz]
    match "/"          , "/"             , {}
    match "/"          , "/foo"          , nil
    match "/foo"       , "/"             , nil
    match "/foo"       , "/foo"          , {}
    match "/:id"       , "/42"           , { :id => "42" }
    match "/:id"       , "/"             , nil
    match "/posts/:id" , "/posts/42"     , { :id => "42" }
    match "/posts/:id" , "/posts"        , nil
    match "/:x/:y"     , "/a/b"          , { :x => "a" , :y => "b" }
    match "/posts"     , "/posts.json"   , { :format => "json" }
    match "/posts/:id" , "/posts/42.json", { :id => "42", :format => "json" }
  end

  def test_match_with_constraints
    r = route('GET', "/posts/:year/:month/:day/:slug",
              :constraints => {
                :year => /\A\d{4}\Z/,
                :month => /\A\d{1,2}\Z/,
                :day => /\A\d{1,2}\Z/},
              :as => "article")
    assert_equal({
      :year => "2012",
      :month => "9",
      :day => "20",
      :slug => "test"
    }, r.match('GET', "/posts/2012/9/20/test"))
    assert_equal(nil, r.match('POST', "/posts/2012/9/20/test"))
    assert_equal(nil, r.match('GET', "/posts/2012/9/20"))
    assert_equal(nil, r.match('GET', "/posts/2012/x/20/test"))
    assert_equal "article", r.name
  end

  def test_eql
    app  = lambda{|env| [200, {}, [""]] }
    assert_equal(
      Rack::Route.new('GET', "/", app),
      Rack::Route.new('GET', "/", app))
  end

  private
  def route(request_method, path, options={})
    Rack::Route.new(request_method, path, lambda{|env| [200, {}, [""]] }, options)
  end

  def match(pattern, path, params)
    msg = "#{caller[0]} expected route #{pattern} to "
    if params
      msg << "match #{path} and return #{params.inspect}"
    else
      msg << "no match #{path}"
    end
    assert_equal(params, route('GET', pattern).match('GET', path), msg)
  end
end

