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
  @word = session[:word]
  @guess = session[:guess]
  erb :game
end

helpers do
  def set_game
    @guesses_left = 6
    @letters_used = []
    session[:word] = get_random_word
  end

   def get_random_word
    dictionary = File.open('lib/hogwartsDictionary.txt').readlines
    word = dictionary[rand(dictionary.length)].strip.downcase
  end
end
