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

  #process guess
  session[:previous_guesses] << session[:guess] unless session[:previous_guesses].include?(session[:guess])
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
    session[:blanks_to_fill] = parse_word_to_blanks(session[:word])
  end

  def display_shit
    @guesses_left = session[:guesses_left]
    @previous_guesses = session[:previous_guesses]
  	@word = session[:word]
  	@word_length = @word.scan(/[a-z]/).length
    @guess = session[:guess]
    @blanks_to_fill = session[:blanks_to_fill]
  end

  def get_random_word
    dictionary = File.open('lib/hogwartsDictionary.txt').readlines
    word = dictionary[rand(dictionary.length)].strip.downcase
  end

  def parse_word_to_blanks(word)
    blanks_to_fill = Array.new(word.length)
    word.split('').each_with_index do |char, idx|
      blanks_to_fill[idx] = char if char =~ /[\s\W]/
    end
    blanks_to_fill
  end



end
