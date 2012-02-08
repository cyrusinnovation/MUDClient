require "socket"

class Client

  SHUTDOWN_MSG = "Lost connection to server."

  attr_reader :host, :port, :socket

  def initialize host, port
    @host = host
    @port = port
  end

  def get_user_input
    $stdin.gets
  end

  def connect
    @socket = TCPSocket.new @host, @port
  end

  def run
    thread = Thread.new do
      server_loop
    end
    client_loop
  end

  def server_loop
    while line = @socket.gets
      display line
    end
  end

  def client_loop
    while line = gets
      write_to_server line
    end
  end

  def write_to_server line
    begin
      socket.puts line
    rescue Errno::EPIPE => e
      shutdown
    end
  end

  def shutdown
    display SHUTDOWN_MSG
    Process.exit
  end

  def display message
    $stdout.puts message
  end

end
