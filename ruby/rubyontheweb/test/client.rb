require 'socket'      # Sockets are in standard library
require 'pry'

hostname = 'localhost'
port = 2000

message = "GET HTTP/1.0\r\n"
message += "Help me\r\n"
p message

s = TCPSocket.open(hostname, port)
s.print message
s.puts "done"
p s.read
s.close               # Close the socket when done
