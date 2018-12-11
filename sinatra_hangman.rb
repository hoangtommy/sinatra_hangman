require 'sinatra'
require 'sinatra/reloader' if development?
require './lib/hangman.rb'

enable :sessions

get '/' do
  set_game
  erb :index
end

post '/game' do
  @guess = params[:guess]
  session[:guess] = @guess

  #process guess
  session[:previous_guesses] << session[:guess] unless session[:previous_guesses].include?(@guess)
  session[:guesses_left] = 6 - session[:previous_guesses].length
  


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
  end

  def display_shit
    @guesses_left = session[:guesses_left]
    @previous_guesses = session[:previous_guesses]
  	@word = session[:word]
  	@word_length = @word.scan(/[a-z]/).length
    @guess = session[:guess]

    @blanks_to_fill = get_feedback(hide(@word))
  end

  def get_random_word
    dictionary = File.open('lib/hogwartsDictionary.txt').readlines
    word = dictionary[rand(dictionary.length)].strip.downcase
  end

  def hide(word)
  	chars = []
  	word.split('').each do |char|
  	  char =~ /[\s\W]/ ? chars << char : chars << nil
  	end
  	chars
  end

  def get_feedback(hidden_chars)
  	feedback = Array.new(@word_length)
    hidden_chars.each_with_index do |char, idx|
      if char.nil?
        feedback[idx] = '__'
      else
        feedback[idx] = char
      end
    end
    feedback.join(' ')
  end

  

end
