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
  redirect "/game?guess=#{@guess}"
end

get '/game' do
  display_shit
  erb :game
end

helpers do
  def set_game
    session[:guesses_left] = 6
    session[:letters_used] = []
    session[:word] = get_random_word
  end

  def display_shit
    @guesses_left = session[:guesses_left]
    @letters_used = session[:letters_used]
  	@word = session[:word]
    @guess = session[:guess]
  end

  def get_random_word
    dictionary = File.open('lib/hogwartsDictionary.txt').readlines
    word = dictionary[rand(dictionary.length)].strip.downcase
  end
end
