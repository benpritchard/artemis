class Capybara::Artemis::Browser

  attr_reader :driver, :last_request, :last_response, :redirect_chain
  attr_accessor :current_host

  def initialize(driver)
    @driver = driver
  end

  def visit(path)
    reset!
    _visit(path)
#     if driver.follow_redirects?
      driver.redirect_limit.times do |i|
        if last_response.redirect?
          redirected_location = last_response.header("location")
          redirected_uri = URI.parse(redirected_location)
          redirected_uri.scheme = @current_scheme unless redirected_uri.scheme
          redirected_uri.host = @current_host unless redirected_uri.host
          redirected_uri.port = @current_port unless redirected_uri.port || @current_port == default_port(@current_scheme)
          @redirect_chain << redirected_uri.to_s
          _visit(redirected_location) if driver.follow_redirects?
        end
      end
      raise Capybara::InfiniteRedirectError, "redirected more than #{driver.redirect_limit} times, check for infinite redirects." if driver.follow_redirects? && last_response.redirect?
#     end
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
    @redirect_chain = []
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
    uri.port ||= @current_port||uri.default_port||default_port(@current_scheme)
    
    @current_scheme = uri.scheme
    @current_host = uri.host
    @current_port = uri.port
    
    reset_cache!
    
    uri = URI.parse(uri.to_s)
    
    @last_request = Capybara::Artemis::Request.new(uri, driver.ignore_ssl_errors?, driver.user_headers)
    @last_response = Capybara::Artemis::Response.new(last_request.go)
  end

  def request_path
    last_request.path
  rescue
    "/"
  end
  
  def default_port(scheme)
    Net::HTTP.send("#{scheme}_default_port")
  end
end
