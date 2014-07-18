class Capybara::Artemis::Response

  def initialize(http_response)
    @response = http_response
  end
  
  def redirect?
    code = @response.code.to_i
    code >= 300 && code < 400
  end
  
  def body
    @response.body
  end
  
  def header(header)
    @response[header]
  end
  
  def raw
    @response
  end
  
  def status
    (@response.code||'').to_i
  end
  
  def headers
    @response.headers
  end
end
