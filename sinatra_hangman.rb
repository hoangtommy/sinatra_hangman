require 'sinatra'
require 'sinatra/reloader' if development?
require './lib/hangman.rb'

enable :sessions

post '/' do
  @guess = params[:guess]
  #validate guess
  session[:guess] = @guess
  redirect '/'
end

get '/' do
  @guess1 = session[:guess]
  erb :index
end
