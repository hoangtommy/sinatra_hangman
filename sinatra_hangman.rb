require 'sinatra'
if development?
  require 'sinatra/reloader'
end

# enable :sessions

# get '/' do
#   'value = ' << session[:value].inspect
# end

# get '/:value' do
#   session['value'] = params['value']
# end

def store_name(filename, string)
  File.open(filename, 'a+') do |file|
  	file.puts(string)
  end
end

get '/' do
  @name = params['email']
  store_name('names.txt', @name)
  erb :index
end

# get '/' do
#   @session = session  
#   erb :index, :locals => {:session => session}
# end