require 'socket'
require 'json'
require 'pry'

class Server
	def initialize
		@server = TCPServer.open(2050)
		@acceptable_requests_array = ['POST', 'GET']
	end

	def start
		loop do
			puts "Waiting for server to accept"
			@server_client = @server.accept
			puts "Server Accepted."
			x = ''
			#request_input_array = prompt_request_input
			#puts "This is request_input_array: #{request_input_array}"
			#parse_request(request_input_array)

			#case @client_request
			#when 'GET'
			#	return_get_website
			#when 'POST'
			#	return_post_website
			#else
			#	server_client.puts "404 #{server_response_array[1][1..-1]} cannot be found."
			#end
			@server_client.close
		end
	end

	private
	
	def return_post_website
		params = JSON.parse(@client_data) 
		return_string = ''

		params["viking"].each do |row|
			return_string << "<li>#{row[0]}: #{row[1]}</li>\n"
		end

		return_string.chop
		template = File.read('./thanks.html')
		template.gsub!("<%= yield %>", return_string)
		File.open('test.html', 'w') {|file| file.puts template}
		@server_client.puts template
	end

	def parse_request(request_input_array)
		@client_request = request_input_array[0]
		@client_path = request_input_array[1][1..-1]
		@client_data = request_input_array.last 
	end

	def return_get_website
		if File.exists?("./#{@client_path}")
			website = File.open("#{@client_path}", 'r').read
			@server_client.puts(website)
		else
			@server_client.puts "404 #{@client_path} cannot be found."
		end
	end

	def prompt_request_input
		@server_client.read.split
	end
end

server = Server.new
server.start
