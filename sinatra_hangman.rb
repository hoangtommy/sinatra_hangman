require 'sinatra'
# require 'sinatra/reloader' if development?
require './lib/hangman.rb'

require 'optimizely'
require 'optimizely/optimizely_factory'

# Production sdk key
sdk_key = 'BkMGxx4GNBK1i35RwNeYES'

# Dev sdk key
# sdk_key = 'TQFkGiY8MGw9ZqRYpnVtnH'

# Initiate Optimizely client
optimizely_instance = Optimizely::OptimizelyFactory.default_instance(sdk_key)

USER_ID = 'user' + rand(100).to_s

# Optimizely activate experiment
@variation = optimizely_instance.activate('hangman', USER_ID)
puts '.....variation is..' + @variation
puts '.....user id is..' + USER_ID

enable :sessions

get '/' do
  set_game
  if @variation == 'original'
    erb :index
  else
    erb :index_variation
  end
end

post '/game' do
  # track click in Optimizely
  optimizely_instance.track('click', USER_ID)
  puts '~~~~~~~~~~~~~~~~tracking click event'

  session[:guess] = params[:guess].downcase

  if session[:previous_guesses].include?(session[:guess])
    session[:error_message] = 'you\'ve already used this guess'
  else
    analyze_guess(session[:guess])
  end

  redirect '/win' if session[:blanks_to_fill].all? { |letter| !letter.nil? } || session[:guess] == session[:word]
  redirect '/lose' if session[:guesses_left] < 1

  redirect "/game?guess=#{@guess}"
end

get '/game' do
  display_variables
  if @variation == 'original'
    erb :game
  else
    erb :game_variation
  end
end

get '/lose' do
  @word = session[:word]
  if @variation == 'original'
    erb :lose
  else
    erb :lose_variation
  end
end

get '/win' do
  @word = session[:word]
  if @variation == 'original'
    erb :win
  else
    erb :win_variation
  end
end

helpers do

  def set_game
    session[:guesses_left] = 6
    session[:previous_guesses] = []
    session[:word] = get_random_word
    session[:blanks_to_fill] = hide_word(session[:word])
  end

  def display_variables
    @guesses_left = session[:guesses_left]
    @previous_guesses = session[:previous_guesses].join(', ')
  	@word = session[:word]
  	@word_length = @word.scan(/[a-z]/).length
    @guess = session[:guess]
    @blanks_to_fill = hide_chars(session[:blanks_to_fill])
    @error_message = session.delete(:error_message)
  end

  def get_random_word
    if @variation == 'original'
      dictionary = File.open('lib/hogwartsDictionary.txt').readlines
    else
      dictionary = File.open('lib/optimizelyDictionary.txt').readlines
    end
    word = dictionary[rand(dictionary.length)].strip.downcase
  end

  def hide_word(word)
    blanks_to_fill = Array.new(word.length)
    word.split('').each_with_index do |char, idx|
      if char =~ /[\s\W]/
        blanks_to_fill[idx] = char
      else
        blanks_to_fill[idx] = nil
      end
    end
    blanks_to_fill
  end

  def hide_chars(blanks_to_fill) # [nil, 'a', nil, nil, 'c']
    feedback = []
    blanks_to_fill.each_with_index do |char, idx|
      if char.nil?
        feedback[idx] = '__'
      elsif char =~ /[\s\W]/
        feedback[idx] = "&nbsp;&nbsp;&nbsp;"
      else
        feedback[idx] = char
      end
    end
    feedback.join(' ')
  end

  def analyze_guess(guess)
    if session[:word].include?(guess)
      session[:word].split('').each_with_index do |letter, idx|
        next if !session[:blanks_to_fill][idx].nil?
        session[:blanks_to_fill][idx] = letter if guess == letter
      end
    else
      update_previous_guesses
      update_guesses_left
    end
  end

  def update_previous_guesses
    session[:previous_guesses] << session[:guess]
  end

  def update_guesses_left
    session[:guesses_left] = 6 - session[:previous_guesses].length
  end

end
