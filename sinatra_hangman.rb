require 'sinatra'
require 'sinatra/reloader' if development?
require './lib/hangman.rb'

enable :sessions

get '/' do
  set_game
  erb :index
end

post '/game' do
  session[:guess] = params[:guess]


  if session[:previous_guesses].include?(session[:guess])
    session[:error_message] = 'you\'ve already used this guess'
  else
    analyze_guess(session[:guess])
  end

  redirect "/game?guess=#{@guess}"
end

get '/game' do
  display_shit
  erb :game
end

helpers do
  def set_game
    session[:guesses_left] = 6
    session[:previous_guesses] = []
    session[:word] = get_random_word
    session[:blanks_to_fill] = turn_word_to_blanks(session[:word])
  end

  def display_shit
    @guesses_left = session[:guesses_left]
    @previous_guesses = session[:previous_guesses]
  	@word = session[:word]
  	@word_length = @word.scan(/[a-z]/).length
    @guess = session[:guess]
    @blanks_to_fill = session[:blanks_to_fill]
    @error_message = session.delete(:error_message)
  end

  def get_random_word
    dictionary = File.open('lib/hogwartsDictionary.txt').readlines
    word = dictionary[rand(dictionary.length)].strip.downcase
  end

  def turn_word_to_blanks(word)
    blanks_to_fill = Array.new(word.length)
    word.split('').each_with_index do |char, idx|
      if char =~ /[\s\W]/
        blanks_to_fill[idx] = char
      else
        blanks_to_fill[idx] = nil
      end
    end
    blanks_to_fill
  end

  def analyze_guess(guess)
    if session[:word].include?(guess)
      session[:word].split('').each_with_index do |letter, idx|
        next if !session[:blanks_to_fill][idx].nil?
        session[:blanks_to_fill][idx] = letter if guess == letter
      end
    else
      #tom, is it okay practice to call two other methods from this helper method?
      update_guesses_left
      update_previous_guesses
    end

    session[:blanks_to_fill]
  end

  def update_previous_guesses
    session[:previous_guesses] << session[:guess]
  end

  def update_guesses_left
    session[:guesses_left] = 6 - session[:previous_guesses].length
  end

end
