require 'sinatra'
if development?
  require 'sinatra/reloader'
end

enable :sessions

# Class can create instances of the game Hangman
class Game

  attr_reader :word

  def initialize
    @games_won ||= 0
    @guesses_left = 6
    @letters_used = []
    @word = 'hello' #get_random_word
    @blanks_to_fill = Array.new(@word.length)

    play_game
  end

  private

  # def new_game
  #   @games_won ||= 0
  #   set_game
  # end

  # def set_game
  #   @guesses_left = 6
  #   @letters_used = []
  #   @word = get_random_word
  #   @blanks_to_fill = Array.new(@word.length)
  #   parse_word_to_blanks
  # end

  def play_game
    until @guesses_left == 0
      # display_feedback(@blanks_to_fill)
      # display_letters_used(@letters_used)
      # display_hangman(@guesses_left)
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

  # def parse_word_to_blanks
  #   @word.split('').each_with_index do |char, idx|
  #     @blanks_to_fill[idx] = char if char =~ /[\s\W]/
  #   end
  # end

  def get_random_word
    dictionary = File.open('hogwartsDictionary.txt', 'r').readlines
    word = dictionary[rand(dictionary.length)].strip.downcase
    word
  end

  def get_player_response
    # display_get_guess
    guess = gets.chomp
    save_game if guess.downcase == 'save'
    until guess.length == 1 || guess.length == @word.length
      # display_error(@word.length)
      guess = gets.chomp
    end
    guess.downcase # Tom: okay to use the same local variable name here and above?
  end

  def end_game(outcome)
    if outcome == 'won'
      @games_won += 1
    end
    set_game
    # display_end_game(outcome, @word, @games_won)
    prompt_replay(outcome)
  end

end

new_game = Game.new

post '/' do
  @guess = params[:guess]
  #validate guess
  session[:guess] = @guess
  redirect '/'
end

get '/' do
  
  @word = new_game.word
  @guess1 = session[:guess]
  erb :index
end
