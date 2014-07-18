# current_url, visit(path), find_xpath(query), find_css(query), html

class Capybara::Artemis::Driver < Capybara::Driver::Base
  DEFAULT_OPTIONS = {
    :ignore_ssl_errors => false,
    :follow_redirects => true,
    :redirect_limit => 5
  }
  attr_reader :app, :options

  def initialize(app, options={})
    @app = app
    @options = DEFAULT_OPTIONS.merge(options)
    @temp_options = {}
  end

  def browser
    @browser ||= Capybara::Artemis::Browser.new(self)
  end

  def user_headers
    options[:headers]||{}
  end

  def ignore_ssl_errors?
    options[:ignore_ssl_errors]
  end

  def follow_redirects?
    options[:follow_redirects]
  end

  def redirect_limit
    options[:redirect_limit]
  end

  def response
    browser.last_response
  end

  def request
    browser.last_request
  end

  def visit(path)
    browser.visit(path)
  end

  def current_url
    browser.current_url
  end

  def response_headers
    response.headers
  end

  def status_code
    response.status
  end

  def find_xpath(selector)
    browser.find(:xpath, selector)
  end
  
  def find_css(selector)
    browser.find(:css,selector)
  end
  
  def html
    browser.html
  end

  def dom
    browser.dom
  end
  
  def title
    browser.title
  end
  
  def options
    @options.merge(@temp_options)
  end
  
  def set_temp_option(hash)
    @temp_options.merge!(hash)
  end
  
  def reset!
    @browser = nil
    @temp_options = {}
  end
end
