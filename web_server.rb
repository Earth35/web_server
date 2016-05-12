require 'socket'
require 'json'

class WebServer
  def initialize
    @server = TCPServer.open('0.0.0.0', 3000)
    @server_signature = "SimpleServer 1.0"
  end
  
  def run
    loop do
      @client = @server.accept
      get_request
      @client.close
    end
  end
  
  def get_request
    request = @client.gets
    if request_valid?(request)
      chunks = request.split(/\s/) # 0: method, 1: path, 3: protocol
      case chunks[0]
        when "GET" then get_send_response(chunks)
        when "POST" then post_send_response(chunks)
      end
    else
      @client.puts "HTTP/1.0 400 Bad Request\r\n"
    end
  end
  
  def request_valid? (request)
    if request =~ /(GET|POST|DELETE|PUT)\s(\.?\/\w++\.\w+)\s(HTTP\/1\.[10])(\\r\\n\\r\\n)?/
      return true
    else
      return false
    end
  end
  
  def get_send_response(chunks)
    if File.exist?(chunks[1])
      response = send_data(chunks)
      @client.print response
    else
      error_404(chunks[2])
    end
  end
  
  def post_send_response (chunks)
    if File.exist?(chunks[1])
      
    else
      error_404(chunks[2])
    end
  end
  
  def send_data (chunks)
    requested_file = File.open(chunks[1], 'r')
    response_body = requested_file.readlines.join
    requested_file.close
    response_initial_line = "#{chunks[2]} 200 OK\r\n"
    last_modified = File.mtime(chunks[1])
    size = File.size(chunks[1])
    response_headers = "Server: #{@server_signature}\r\nLast-Modified: #{last_modified}\r\nContent-Length: #{size} bytes\r\n"
    return response = response_initial_line + response_headers + response_body
  end
  
  def error_404 (protocol)
    @client.print "#{protocol} 404 Not Found\r\nRequested file was not found on the server.\r\n"
  end
end

server = WebServer.new
server.run