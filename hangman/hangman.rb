require 'YAML'
require 'pry'
# List of stuff to do:
# - Refactor code
# - Check if transfer_save works
# - Create test cases
# - Create save input functions

class Word
	attr_reader :hash_array, :secret
	def initialize(word)
		@secret = word
		@hash_array = @secret.each_char.map do |letter|
			{ letter: letter, is_revealed?: false}
		end
	end

	# Returns true if all characters have been revealed; Returns false otherwise
	def everything_revealed?
		hash_array.count {|hash| hash[:is_revealed?] == true} == hash_array.length ? true : false
	end

	def set_equal(rhs)
		@hash_array = rhs.hash_array
		@secret = rhs.secret
	end
end

class Player
	attr_accessor :choice, :name
	def initialize(name= '')
		@name = name
		@choice = []
	end

	def set_equal(rhs)
		@name = rhs.name
	end
end

class SaveFile
	attr_reader :name, :reader
	attr_accessor :data
	@@save_file_counter = 0
	def initialize(yaml)
		@name = @@save_file_counter
		@date_created = Time.now
		@data = yaml
		@@save_file_counter += 1
	end

	def to_s
		"#{@name} | #{@date_created}"
	end
end

class Hangman
	attr_reader :player, :hangman_string, :points, :wrong_letters, :guesses_left, :player, :word
	@@save_files = []

	def initialize
		@file = File.read('5desk.txt')
		@file_array = @file.split
		@hangman_string = initialize_hangman
		@points = 0
		@wrong_letters = []
		@guesses_left = 5
		@player = Player.new
		@player.name = prompt_player_name
	end

	######## SAVE AND LOAD FEATURES ########
	public
	def save
		yaml_holder = YAML::dump(self)
		save_file = SaveFile.new(yaml_holder)
		@@save_files.push(save_file)
		puts "File saved."
		sleep(1)
	end

	def load
		p "This is user input: #{@player.choice}"
		puts "which save file which you like to load?"
		@@save_files.each {|save_file| puts save_file}
		user_input = gets.chomp.to_i
		# TODO: Find function that returns object if found, nil if nothing
		save_file = @@save_files.find {|temp_save_file| temp_save_file.name == user_input}
		
		p "This is user input line 91: #{@player.choice}"
		if save_file.nil?
			puts "File not found."
			sleep(1)
			return nil
		end
		
		p "This is user input line 98: #{@player.choice}"
		transfer_save(save_file)
		p "This is user input line 100: #{@player.choice}"
		# TODO: find a way to load a save file
		# Save file is Hangman format. I want to find a way to transfer one file's components to another file.
		# How do we transfer one file's contents to another file
	end

	######## MAIN FUNCTION #########
	def play
		loop do
			p @player.choice.join
			@word = Word.new(generate_word) unless input_is_load?(@player.choice.join)
			loop do
				prep_screen
				@player.choice = prompt_player
				if input_is_save?(@player.choice.join)
					save
					next
				end
				break if input_is_load?(@player.choice.join)
				mark_word

				if lost?
					display_lost
					break
				elsif won?
					display_won
					break
				end
			end

			if input_is_load?(@player.choice.join)
				load
				next
			end
			play_again? ? prep_game : break
		end
	end


	private


	# This will randomly select a word between 5 and 12 characters long
	# RETURNS: String word
	def generate_word
		@file_array.select{|word| word.length >= 5 && word.length <= 12}.sample
	end

	def mark_word
		@player.choice.each do |player_letter|
			@word.hash_array.each_with_index do |hash_array, index|
				if hash_array[:letter].downcase == player_letter.downcase && hash_array[:is_revealed?] == false
					@word.hash_array[index][:is_revealed?] = true 
					@points += 1
					break
				elsif hash_array[:letter].downcase != player_letter.downcase && @wrong_letters.include?(player_letter) == false
					# If player_letter
					if index != @word.hash_array.length - 1 
						next
					else
						@guesses_left -= 1
						@wrong_letters.push(player_letter)
					end
				end
			end
		end
	end

	# Returns true or false depending on whether player has run of guesses or not
	def lost?
		return true if @guesses_left <= 0
		return false
	end

	# Returns true or false depending on whether player has guessed all the letters of the word
	def won?
		@word.everything_revealed? ? true : false
	end

	# Preps game
	def prep_game
		@hangman_string = initialize_hangman
		@points = 0
		@wrong_letters = []
		@guesses_left = 5
	end

	# Preps the screen
	def prep_screen
		clear_screen
		display_screen
	end

	# This initializes hangman
	def initialize_hangman
		return_array = []
		return_array.push "---------  "
		return_array.push "|       |  "
		return_array.push "|          "
		return_array.push "|          "
		return_array.push "|          "
		return_array.push "___________"
		return_array
	end

	# This clears screen
	def clear_screen
		system('clear')
	end

	# Prompts player whether they want to play aagin or not.
	def play_again?
		user_input = ''
		puts "Do you wish to play again? (y/n)"
		user_input = gets.chomp.downcase
		user_input.include?('y') ? true : false
	end

	# Displays player lost screen
	def display_lost
		puts "#{@player.name}, you have lost."
		puts "The secret word was: #{@word.secret}"
	end

	# Displays player won screen
	def display_won
		puts "#{@player.name}, you have won!"
	end

	# This displays hangman
	def display_screen
		@hangman_string.each{|line| puts line}
		display_word
		puts "Points: #{@points}"
		puts "Incorrect letters: #{@wrong_letters.join}"
		puts "Guesses left: #{@guesses_left}"
	end

	# This displays the word
	def display_word
		puts 
		@word.hash_array.each do |letter_hash_array|
			if letter_hash_array[:is_revealed?] == false
				print "_"
			else
				print letter_hash_array[:letter]
			end
		end
		print "\n\n"
	end

	# Asks player what letter they want to choose
	def prompt_player
		player_choice = ''
		loop do
			puts "#{@player.name}, choose a letter or letters: "
			player_choice = gets.chomp
			break if player_choice != nil && player_choice.split.join.scan(/[^a-zA-Z]/).length == 0
			puts "please choose a valid choice."
		end
		player_choice.split.join.split("")
	end

	# Askes player their name
	def prompt_player_name
		puts "What is your name?"
		gets.chomp
	end

	########################################
	######## SAVE PRIVATE FUNCTIONS ########
	########################################
	
	def transfer_save(save_file)
		hangman_object = YAML::load(save_file.data)
		@hangman_string = hangman_object.hangman_string
		@points = hangman_object.points
		@guesses_left = hangman_object.guesses_left
		@player.set_equal(hangman_object.player)
		@wrong_letters = hangman_object.wrong_letters
		@word.set_equal(hangman_object.word)
	end
	
	def input_is_save?(user_input)
		(user_input.downcase == 'save') ? true : false
	end

	########################################
	######## LOAD PRIVATE FUNCTIONS ########
	########################################
	
	def input_is_load?(user_input)
		(user_input.downcase == 'load') ? true : false
	end
end

game = Hangman.new
game.play
