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

  def display_hangman(turns_left)
  	case(turns_left)
  	when 5
  	 puts 'turns left: ϟϟϟϟϟ'
  	when 4
  	 puts 'turns left: ϟϟϟϟ'
  	when 3
  	 puts 'turns left: ϟϟϟ'
  	when 2
  	 puts 'turns left: ϟϟ'
  	when 1
  	 puts 'turns left: ϟ'
  	end
  end

  def display_letters_used(letters)
  	puts "Letters used: #{letters.join(', ')}"
  	puts ''
  end

  

end
