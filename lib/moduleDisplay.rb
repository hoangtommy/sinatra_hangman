# These methods are all used to print things to the screen
module Display
  def display_instructions
  	puts ''
  	puts 'Welcome to Hangman: The Hogwarts Editions ⌁☍'
  	puts ''
  	3.times do 
  	  print '.'
  	  sleep(0.3)
  	end
  	puts ''
  	puts ''
  	puts 'Like the regular hangman, you\'ll be given a word represented by blank spaces.
  		You will have 6 guesses to figure out the word. 
  		You can guess a single letter or you can attempt to guess the entire word. 
  		If guessing the entire word, you won\'t get feedback on which letters are and aren\'t present.
  		To save the game at any time, type in \'save\''
  	puts ''
  	puts 'Press ENTER for the main menu'
  	gets
  end

  def display_game_options
  	puts ''
  	puts ''
  	puts 'Main Menu ❾¾'
  	puts "Type '1' to Start New Game"
  	puts "Type '2' to Load Existing Game"
  	puts ''
  end

  def display_get_name
  	puts 'What\'s your wizarding name?'
  end

  def display_name_error
  	puts 'We don\'t have that name on record. Have you played and saved a game before? Please try another name.'
  	puts ''
  end

  def display_get_player_name
  	puts 'Type in your wizarding name.'
  end

  def display_farewell(name)
  	puts "Thanks for playing #{name}!"
  	puts "Come back to Ravenclaw's game room anytime!"
  end

  def display_blanks(word)
  	word_length = word.include?(' ') ? word.length - 1 : word.length
  	puts "What's a #{word_length} letter word."
  	puts ''
  	temp = []
  	word.split('').each do |letter|
  	  letter =~ /[\s\W]/ ? temp << letter : temp << nil
  	end
  	display_feedback(temp)
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
  	puts ''
  	puts ''
  end

  def display_letters_used(letters)
  	puts "Letters used: #{letters.join(', ')}"
  	puts ''
  end

  def display_feedback(hidden_word) # [nil, 'a', nil, nil, 'c']
  	num_of_special_chars = hidden_word.count { |letter| letter =~ /[\s\W]/ }
    length = hidden_word.length - num_of_special_chars
  	feedback = Array.new(length)
    hidden_word.each_with_index do |letter, idx|
      if letter.nil?
        feedback[idx] = '__'
      else
        feedback[idx] = letter
      end
    end
  	puts ''
    puts "An #{length} letter word."
  	puts ''
  	puts feedback.join(' ')
  	puts ''
  	puts ''
  end

  def display_get_guess
  	puts ''
  	puts 'Your guess:'
  end

  def display_error(word_length)
  	puts "Please type in a single letter or a #{word_length} letter word."
  end

  def display_letter_exist_error
  	puts 'You\'ve already used this letter'
  end

  def display_end_game(outcome, word, games_won)
  	if outcome == 'won'
  	  puts "You guessed it, #{word}!"
  	else
  	  puts "You might be more muggle than you thought! The word was '#{word}'"
  	  sleep(0.5)
  	  puts 'Just kidding, being good at word guessing doesn\'t mean you\'d make a bad witch/wizard'
  	end
    puts "Total words corrects: #{games_won}"
  	puts ''
  end

  def display_replay_message(outcome)
  	puts "Since you #{outcome}, do you want to play again?"
  	puts "Type in 'y' for yes"
    puts "Type in 'n' to quit"
  end

  def display_replay_error
    puts "Please type 'y' to play another game or 'n' to quit."
  end

  def display_save_game?
    puts 'Would you like to save your game? (y/n)'
  end
end
