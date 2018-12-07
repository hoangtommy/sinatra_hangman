# Class can create instances of the game Hangman
class Game
  require './moduleDisplay.rb'
  require 'json'

  include Display

  def initialize
  	display_instructions
  	get_game_options
  	play_game
  end

  private

  def get_game_options
  	display_game_options
  	response = gets.chomp
  	response.downcase == '2' ? load_game : new_game
  end

  def load_game
  	display_get_name
  	name = gets.chomp
  	filename = "saved_games/#{name.capitalize}_HogwartsHangman.json"
  	until File.exist?(filename) do
  	  display_name_error
  	  name = gets.chomp
  	  filename = "saved_games/#{name.capitalize}_HogwartsHangman.json"
  	end
  	set_game_files(filename)
  end

  def set_game_files(filename)
  	saved_game = JSON.parse(File.read(filename))
  	@guesses_left = saved_game['guesses_left']
  	@letters_used = saved_game['letters_used']
  	@word = saved_game['word']
  	@blanks_to_fill = saved_game['blanks_to_fill']
  	@games_won = saved_game['games_won']
  	@player_name = saved_game['player_name']
  end

  def new_game
  	@games_won ||= 0
  	set_game
  end

  def set_game
    @guesses_left = 6
    @letters_used = []
    @word = get_random_word
    @blanks_to_fill = Array.new(@word.length)
    parse_word_to_blanks
  end

  def play_game
  	until @guesses_left == 0
  	  display_feedback(@blanks_to_fill)
  	  display_letters_used(@letters_used)
  	  display_hangman(@guesses_left)
  	  guess = get_player_response
  	  analyze_guess(guess)
	  end_game('won') if @blanks_to_fill.all? { |letter| !letter.nil? } || guess == @word
  	end
  	end_game('loss')
  end

  def analyze_guess(guess)
  	if @word.include?(guess)
  	  @word.split('').each_with_index do |letter, idx|
  	  	next if !@blanks_to_fill[idx].nil?
  	  	# @blanks_to_fill[idx] = letter if letter =~ /[\s\W]/
  	  	@blanks_to_fill[idx] = letter if guess == letter
  	  end
  	else
  	  @letters_used << guess if guess.length == 1 && !@letters_used.include?(guess)
  	  @guesses_left -= 1
  	end
  end

  def parse_word_to_blanks
  	@word.split('').each_with_index do |char, idx|
  	  @blanks_to_fill[idx] = char if char =~ /[\s\W]/
    end
  end

  def get_player_name
  	display_get_player_name
  	name = gets.chomp
  	display_farewell(name)
  	name.capitalize
  end

  def get_random_word
    dictionary = File.open('hogwartsDictionary.txt', 'r').readlines
    word = dictionary[rand(dictionary.length)].strip.downcase
    word
  end

  def get_player_response
  	display_get_guess
  	guess = gets.chomp
  	save_game if guess.downcase == 'save'
  	until guess.length == 1 || guess.length == @word.length
  	  display_error(@word.length)
  	  guess = gets.chomp
  	end
  	guess.downcase # Tom: okay to use the same local variable name here and above?
  end

  def save_game
  	@player_name = get_player_name
  	gameFile = {
	  	:guesses_left => @guesses_left,
	  	:letters_used => @letters_used,
	    :word => @word,
	    :blanks_to_fill => @blanks_to_fill,
	  	:games_won => @games_won,
	  	:player_name => @player_name
    }

  	Dir.mkdir('saved_games') unless Dir.exist?('saved_games')
  	filename = "saved_games/#{@player_name}_HogwartsHangman.json"
  	File.open(filename, 'w') do |file|
  	  file.write(gameFile.to_json)
  	end
  	puts 'Your game is saved. Use your wizarding name to access it when you return.'
  	exit
  end

  def end_game(outcome)
  	if outcome == 'won'
  	  @games_won += 1
  	end
    set_game
  	display_end_game(outcome, @word, @games_won)
  	prompt_replay(outcome)
  end

  def prompt_replay(outcome)
  	display_replay_message(outcome)
  	response = gets.chomp
  	response.downcase
    until response == 'y' || response == 'n'
      display_replay_error
      response = gets.chomp
    end
  	if response == 'y'
  	  set_game
  	  play_game
  	elsif response == 'n'
  	  display_save_game?
      answer = gets.chomp
      save_game if answer == 'y'
      exit
  	end
  end
end

n = Game.new
