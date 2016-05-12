require 'socket'
require 'json'

class Browser
  def initialize
    @host = 'localhost'
    @port = 3000
    @get_path = "./index.html"
    @post_path = "./thanks.html"
    @user_agent = "SimpleBrowser/1.0"
  end
  
  def send_request
    puts "What kind of request would you like to send? (GET/POST)?"
    type = gets.chomp.upcase
    until type =~ /^GET|POST$/
      puts "Incorrect input:"
      type = gets.chomp.upcase
    end
    case type
      when "GET" then send_get_request
      when "POST" then send_post_request
    end
    return stop?
  end
  
  private
  
  def send_get_request
    request = "GET #{@get_path} HTTP/1.0\r\n\r\n"
    socket = TCPSocket.open(@host, @port)
    socket.print(request)
    get_response(socket)
  end
  
  def send_post_request
    user_data = get_info
    from = user_data[:viking][:email]
    body = user_data.to_json
    initial_line = "POST #{@post_path} HTTP/1.0\r\n"
    headers = "From: #{from}\r\n" + "User-Agent: #{@user_agent}\r\n" + "Content-Type: JSON\r\n" + "Content-Length: #{body.bytesize}\r\n"
    request = initial_line + headers + "\r\n" + body
    socket = TCPSocket.open(@host, @port)
    socket.print(request)
    get_response(socket)
  end
  
  def get_response (socket)
    response = socket.read
    print response
  end
  
  def get_info
    puts "Registering for a raid."
    puts "What's your name?"
    name = gets.chomp.capitalize
    puts "Please enter your e-mail address so we can contact you:"
    email = gets.chomp
    while email !~ /(\w+\.?)+@\w+\.\w{2,3}/
      puts "Please enter a valid e-mail address:"
      email = gets.chomp
    end
    participant = {name: name, email: email}
    data = {viking: participant}
  end
  
  def stop?
    puts "\nSend another request (y/n)?"
    input = gets.chomp.downcase
    until input =~ /^[yn]$/
      puts "Incorrect input, y/n only:"
      input = gets.chomp.downcase
    end
    return true if input == "n"
  end
end

browser = Browser.new
stop = false
until stop
  stop = browser.send_request
end