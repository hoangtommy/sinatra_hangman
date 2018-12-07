require 'sinatra'
require 'sinatra/reloader' if development?
require './lib/hangman.rb'

enable :sessions

get '/' do
  erb :index
end

post '/game' do
  @guess = params[:guess]
  session[:guess] = @guess
  redirect "/game?guess=#{@guess}"
end

get '/game' do
  @word = get_random_word
  @guess = session[:guess]
  erb :game
end

helpers do
  def set_game
    @guesses_left = 6
    @letters_used = []
    @word = get_random_word
    session[:word] = @word
    # @blanks_to_fill = Array.new(@word.length)
  end

   def get_random_word
    dictionary = File.open('lib/hogwartsDictionary.txt').readlines
    word = dictionary[rand(dictionary.length)].strip.downcase
  end
end
