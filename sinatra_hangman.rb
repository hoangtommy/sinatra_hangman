require 'sinatra'
require 'sinatra/reloader' if development?
require './lib/hangman.rb'

enable :sessions

get '/' do
  set_game
  erb :index
end

post '/game' do
  session[:guess] = params[:guess].downcase

  if session[:previous_guesses].include?(session[:guess])
    session[:error_message] = 'you\'ve already used this guess'
  else
    analyze_guess(session[:guess])
  end

  redirect '/win' if session[:blanks_to_fill].all? { |letter| !letter.nil? } || session[:guess] == session[:word]
  redirect '/lose' if session[:guesses_left] < 1

  redirect "/game?guess=#{@guess}"
end

get '/game' do
  display_variables
  erb :game
end

get '/lose' do
  @word = session[:word]
  erb :lose
end

get '/win' do
  @word = session[:word]
  erb :win
end

helpers do

  def set_game
    session[:guesses_left] = 6
    session[:previous_guesses] = []
    session[:word] = get_random_word
    session[:blanks_to_fill] = hide_word(session[:word])
  end

  def display_variables
    @guesses_left = session[:guesses_left]
    @previous_guesses = session[:previous_guesses].join(', ')
  	@word = session[:word]
  	@word_length = @word.scan(/[a-z]/).length
    @guess = session[:guess]
    @blanks_to_fill = hide_chars(session[:blanks_to_fill])
    @error_message = session.delete(:error_message)
  end

  def get_random_word
    dictionary = File.open('lib/hogwartsDictionary.txt').readlines
    word = dictionary[rand(dictionary.length)].strip.downcase
  end

  def hide_word(word)
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

  def hide_chars(blanks_to_fill) # [nil, 'a', nil, nil, 'c']
    feedback = []
    blanks_to_fill.each_with_index do |char, idx|
      if char.nil?
        feedback[idx] = '__'
      elsif char =~ /[\s\W]/
        feedback[idx] = "&nbsp;&nbsp;&nbsp;"
      else
        feedback[idx] = char
      end
    end
    feedback.join(' ')
  end

  def analyze_guess(guess)
    if session[:word].include?(guess)
      session[:word].split('').each_with_index do |letter, idx|
        next if !session[:blanks_to_fill][idx].nil?
        session[:blanks_to_fill][idx] = letter if guess == letter
      end
    else
      update_previous_guesses
      update_guesses_left
    end
  end

  def update_previous_guesses
    session[:previous_guesses] << session[:guess]
  end

  def update_guesses_left
    session[:guesses_left] = 6 - session[:previous_guesses].length
  end

end
