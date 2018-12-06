require 'sinatra'
if development?
  require 'sinatra/reloader'
end

enable :sessions

# writing to an external file
def store_name(filename, string)
  File.open(filename, 'a+') do |file|
  	file.puts(string)
  end
end

def read_names
  return [] unless File.exist?('names.txt')
  File.read('names.txt').split('\n')
end


post '/index' do
  @name = params[:name]
  store_name('names.txt', @name)
  session[:message] = "successfully logged #{@name}."
  redirect "/index?name=#{@name}"
end

get '/index' do
  @message = session[:message]
  @name = params[:name]
  @names = read_names
  erb :index
end