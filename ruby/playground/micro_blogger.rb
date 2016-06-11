require 'jumpstart_auth'

class MicroBlogger
	attr_reader :client

	def initialize
		puts "Initializing..."
		@client = JumpstartAuth.twitter
	end

	def run
		loop do
			clear_screen
			puts "Welcome to TwiiterBot."
			puts "What would you like to do?"
			print "T.) Tweet\nQ.) quit\n" 

			user_whole_input_array = gets.chomp.split
			user_input = user_whole_input_array.shift
			user_whole_input_string = user_whole_input_array.join(" ")
			p user_input

			case user_input.downcase
			when 't'
				(user_whole_input_array.empty?) ? tweet : tweet(user_whole_input_string)
				puts 'tweeting...'
				sleep(2.5)
			when 'q'
				break
			when 'dm'
			else
				puts "error detected"
			end
		end
	end

	private

	def dm (target, message)
		puts "Trying to send #{target} this direct message:\n#{message}"
	end

	def tweet(message)
		message = prompt_input if message.nil?
		return message if message == 'quit'
		@client.update(message)
		message
	end

	def prompt_input
		puts "What would you like to tweet?"
		gets.chomp[0...140]
	end

	def clear_screen
		system "clear"
	end
end

blog = MicroBlogger.new
blog.run
