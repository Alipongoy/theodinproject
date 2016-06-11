require 'socket'               # Get sockets from stdlib
require 'pry'

server = TCPServer.open(2000)  # Socket to listen on port 2000
loop {                         # Servers run forever
	puts "#{Time.new.ctime} ---- 1"
	client = server.accept       # Wait for a client to connect
	puts "#{Time.new.ctime} ---- 2"
	p client.read_nonblock(256)
	puts "#{Time.new.ctime} ---- 3"

	client.puts(Time.now.ctime)  # Send the time to the client
	client.puts "Closing this shit. Bye!"
	client.puts "Actually just kidding its just a prank bro"
	client.print "Actually just kidding its just a prank bro"
	client.close                 # Disconnect from the client
	puts "#{Time.new.ctime} ---- 4"
}

