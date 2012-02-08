require_relative "test_helper"

require "client"

class ClientTest < Test::Unit::TestCase

  TEST_HOST = "127.0.0.1"
  TEST_PORT = 10101

  def setup
    @client = Client.new TEST_HOST, TEST_PORT
  end

  def teardown
    $stdin = STDIN
    $stdout = STDOUT
  end

  def test_initializer_stores_host_and_port
    assert_equal TEST_HOST, @client.host
    assert_equal TEST_PORT, @client.port
  end

  def test_get_user_input
    input_string = "hi there"
    input = StringIO.new input_string
    $stdin = input
    assert_equal input_string, @client.get_user_input
  end

  def test_connect_creates_tcpsocket
    fake_socket = mock
    TCPSocket.expects(:new).with(@client.host, @client.port).returns(fake_socket)
    @client.connect
    assert_equal fake_socket, @client.socket
  end

  def test_write_to_server_handles_broken_pipe
    socket = mock
    socket.stubs(:puts).raises(Errno::EPIPE)
    @client.stubs(:socket).returns(socket)
    @client.expects(:shutdown)
    assert_nothing_raised do
      @client.write_to_server "foo"
    end
  end

  def test_shutdown
    @client.expects(:display).with(Client::SHUTDOWN_MSG)
    Process.expects(:exit)
    @client.shutdown
  end

  def test_display
    message = "moo"
    $stdout.expects(:puts).with(message)
    @client.display message
  end

end
