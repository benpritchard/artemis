class Capybara::Artemis::Browser

  attr_reader :driver, :last_request, :last_response
  attr_accessor :current_host

  def initialize(driver)
    @driver = driver
  end

  def visit(path)
    reset!
    _visit(path)
    if driver.follow_redirects?
      driver.redirect_limit.times do |i|
        _visit(last_response.header("location")) if last_response.redirect?
      end
      raise Capybara::InfiniteRedirectError, "redirected more than #{driver.redirect_limit} times, check for infinite redirects." if last_response.redirect?
    end
  end

  def current_url
    last_request.url
  rescue
    ""
  end

  def reset!
    uri = URI.parse(Capybara.app_host || Capybara.default_host)
    @current_scheme = uri.scheme
    @current_host = uri.host
    @current_port = uri.port
    @last_request = nil
    @last_response = nil
    @temp_options = {}
    reset_cache!
  end

  def reset_cache!
    @dom = nil
  end

  def dom
    @dom ||= Capybara::HTML(html)
  end

  def find(format, selector)
    if format==:css
      dom.css(selector)
    else
      dom.xpath(selector)
    end.map { |node| Capybara::Artemis::Node.new(self, node) }
  end

  def html
    last_response.body
  rescue
    ""
  end

  def title
    dom.xpath("//title").text
  end
  
protected

  def _visit(path)
    uri = URI.parse(path)
    uri.path = request_path if path.start_with?("?")
    uri.path = "/" if uri.path.empty?
    uri.path = request_path.sub(%r(/[^/]*$), '/') + uri.path unless uri.path.start_with?('/')
    
    uri.scheme ||= @current_scheme
    uri.host ||= @current_host
    uri.port ||= @current_port unless uri.default_port == @current_port || (uri.default_port.nil? && @current_port == default_port)
    
    @current_scheme = uri.scheme
    @current_host = uri.host
    @current_port = uri.port
    
    reset_cache!
    
    @last_request = Capybara::Artemis::Request.new(uri, driver.ignore_ssl_errors?, driver.user_headers)
    @last_response = Capybara::Artemis::Response.new(last_request.go)
  end

  def request_path
    last_request.path
  rescue
    "/"
  end
  
  def default_port
    @default_port ||= begin
      uri = URI.parse('http://www.example.com')
      uri.default_port
    end
  end
end
