require 'net/http'

class Capybara::Artemis::Request

  def initialize(uri, ignore_ssl_errors, headers)
    @uri = uri
    @ignore_ssl_errors = ignore_ssl_errors
    @request = Net::HTTP::Get.new(@uri.request_uri)
    
    headers.each_pair do |header, value|
      @request[header.to_s] = value
    end
  end
  
  def go
    http = Net::HTTP.new(@uri.host, @uri.port)
    http.use_ssl = @uri.scheme == 'https'
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if @ignore_ssl_errors
    http.request(@request)
  end
  
  def url
    @uri.to_s
  end
  
  def path
    @uri.path
  end
end
