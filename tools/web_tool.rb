require 'net/http'
require 'json'
require 'uri'

class WebTool < LlmGateway::Tool
  name 'Web'
  description 'Make HTTP/HTTPS requests to fetch data and call APIs'
  input_schema({
    type: 'object',
    properties: {
      url: { type: 'string', description: 'URL to request' },
      method: {
        type: 'string',
        enum: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
        description: 'HTTP method (default: GET)'
      },
      headers: { type: 'object', description: 'HTTP headers as key-value pairs' },
      body: { type: 'string', description: 'Request body (for POST/PUT/PATCH)' },
      timeout: { type: 'integer', description: 'Timeout in seconds (default: 30)' }
    },
    required: ['url']
  })

  def execute(input)
    url = input[:url]
    method = input[:method] || 'GET'
    headers = input[:headers] || {}
    body = input[:body]
    timeout = input[:timeout] || 30

    uri = URI.parse(url)
    
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.read_timeout = timeout
    http.open_timeout = timeout

    request = case method.upcase
              when 'GET' then Net::HTTP::Get.new(uri.request_uri)
              when 'POST' then Net::HTTP::Post.new(uri.request_uri)
              when 'PUT' then Net::HTTP::Put.new(uri.request_uri)
              when 'DELETE' then Net::HTTP::Delete.new(uri.request_uri)
              when 'PATCH' then Net::HTTP::Patch.new(uri.request_uri)
              else
                return "Error: Unsupported HTTP method '#{method}'"
              end

    headers.each { |key, value| request[key] = value }
    request.body = body if body && ['POST', 'PUT', 'PATCH'].include?(method.upcase)

    response = http.request(request)
    
    output = "HTTP #{response.code} #{response.message}\n"
    output += "Headers:\n"
    response.each_header { |key, value| output += "  #{key}: #{value}\n" }
    output += "\nBody:\n#{response.body}"
    
    output
  rescue => e
    "Error making HTTP request: #{e.message}"
  end
end
