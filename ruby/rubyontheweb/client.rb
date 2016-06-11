require 'socket'
require 'json'
require 'pry'

class Client
	def initialize
		@hostname = 'localhost'
		@port = '2050'
		@socket = TCPSocket.open(@hostname, @port)
		@acceptable_requests_array = ['POST', 'GET']
	end

	def start
		user_request = prompt_request_input

		case user_request
		when 'POST'
			viking_data_hash = prompt_viking_data
			@viking_json = viking_data_hash.to_json
			puts "About to send POST data"
			p generate_post_response
			p generate_post_response.split
			@socket.puts(generate_post_response)
			puts "Sent POST data"
		when 'GET'
			puts "About to send GET data"
			p generate_get_response
			@socket.print(generate_get_response())
			puts "Sent GET data"
		end
		
		while s = @socket.gets
			puts s.chop
		end
		@socket.close
	end

	private

	def generate_get_response
		"GET /index.html HTTP/1.0\n"
	end

	def generate_post_response	
		return_string = "POST /thanks.html HTTP/1.0\n"
		return_string << "Content-Length: #{@viking_json.bytesize}\r\n#{@viking_json}\n"
		File.open('gg.txt', 'w') {|file| file.puts return_string}
		return_string
	end

	def prompt_request_input
		loop do
			puts "What type if request would you like to send?"
			user_input = gets.chomp.upcase
			(@acceptable_requests_array.include?(user_input)) ? (return user_input) : (puts "Request invalid. please type another request.")
		end
	end

	# Returns a hash with Viking information
	def prompt_viking_data
		clear_screen
		prompt_string = "VIKING INFORMATION\n"
		puts prompt_string.ljust( (prompt_string.length * 2) - 1, '-')
		print 'name: '
		user_name = gets.chomp
		print 'email: '
		user_email = gets.chomp

		result_hash = {
			viking: {
				name: user_name,
				email: user_email
			}
		}
		result_hash
	end

	def clear_screen
		system "clear"
	end
end

client = Client.new
client.start
#request = "POST #{path} HTTP/1.0\r\n\r\n"

