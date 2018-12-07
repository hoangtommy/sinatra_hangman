require 'sinatra'
require 'sinatra/reloader' if development?
require './lib/hangman.rb'

enable :sessions

get '/' do
  erb :index
end

post '/game' do
  @guess = params[:guess]
  #validate guess
  session[:guess] = @guess
  redirect "/game?guess=#{@guess}"
end

get '/game' do
  @guess1 = session[:guess]
  erb :game
end
