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

  redirect '/win' if session[:blanks_to_fill].all? { |letter| !letter.nil? } || session[:guess] == session[:word]
  redirect '/lose' if session[:guesses_left] < 1

  redirect "/game?guess=#{@guess}"
end

get '/game' do
  display_shit
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
    session[:blanks_to_fill] = hide_letters(session[:word])
  end

  def display_shit
    @guesses_left = session[:guesses_left]
    @previous_guesses = session[:previous_guesses]
  	@word = session[:word]
  	@word_length = @word.scan(/[a-z]/).length
    @guess = session[:guess]
    @blanks_to_fill = display_feedback(session[:blanks_to_fill])
    @error_message = session.delete(:error_message)
  end

  def get_random_word
    dictionary = File.open('lib/hogwartsDictionary.txt').readlines
    word = dictionary[rand(dictionary.length)].strip.downcase
  end

  def hide_letters(word)
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
    #had to use session[:word] here since it seems I can't access @instance variables @word
    if session[:word].include?(guess)
      session[:word].split('').each_with_index do |letter, idx|
        next if !session[:blanks_to_fill][idx].nil?
        session[:blanks_to_fill][idx] = letter if guess == letter
      end
    else
      #tom, is it okay practice to call two other methods from this helper method?
      update_previous_guesses
      update_guesses_left
    end
  end

  def display_feedback(hidden_word) # [nil, 'a', nil, nil, 'c']
    feedback = []
    hidden_word.each_with_index do |char, idx|
      if char.nil?
        feedback[idx] = '__'
      # elsif char =~ /[\s\W]/
      #   feedback[idx] = " space "
      else
        feedback[idx] = char
      end
    end
    feedback.join(' ')
  end

  def update_previous_guesses
    session[:previous_guesses] << session[:guess]
  end

  def update_guesses_left
    session[:guesses_left] = 6 - session[:previous_guesses].length
  end

end
