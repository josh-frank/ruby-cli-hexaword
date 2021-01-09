# $TEMPLATE = [
#     "      ╱▔▔▔╲      ",
#     "     ╱  1  ╲     ",
#     " ╱▔▔▔╲     ╱▔▔▔╲ ",
#     "╱  6  ╲▁▁▁╱  2  ╲",
#     "╲     ╱   ╲     ╱",
#     " ╲▁▁▁╱  0  ╲▁▁▁╱ ",
#     " ╱   ╲     ╱   ╲ ",
#     "╱  5  ╲▁▁▁╱  3  ╲",
#     "╲     ╱   ╲     ╱",
#     " ╲▁▁▁╱  4  ╲▁▁▁╱ ",
#     "     ╲     ╱     ",
#     "      ╲▁▁▁╱      "
# ]

require 'tty-prompt'
require 'colorize'
require 'pry'

class Puzzle

    @@dictionary = File.open( "words.txt" ).read.split( "\r\n" )

    attr_reader :match, :pangram
    attr_accessor :letters, :guesses

    def initialize( these_letters )
        raise ArgumentError, "Puzzle must contain exactly 7 letters" unless these_letters.length == 7
        @letters = these_letters.upcase
        @guesses = []
        @match = /^(?=.*#{ these_letters.upcase[ 0 ] })[#{ these_letters.upcase }]{4,}+$/
        @pangram = /^(?=.*#{ these_letters.upcase[ 0 ] })(?=.*#{ these_letters.upcase[ 1 ] })(?=.*#{ these_letters.upcase[ 2 ] })(?=.*#{ these_letters.upcase[ 3 ] })(?=.*#{ these_letters.upcase[ 4 ] })(?=.*#{ these_letters.upcase[ 5 ] })(?=.*#{ these_letters.upcase[ 6 ] })[#{ these_letters.upcase }]+$/
    end

    def to_s
        [ "      ╱▔▔▔╲      ",
        "     ╱  1  ╲     ".gsub( "1", self.letters[ 1 ] ),
        " ╱▔▔▔╲     ╱▔▔▔╲ ",
        "╱  6  ╲▁▁▁╱  2  ╲".gsub( "6", self.letters[ 6 ] ).gsub( "2", self.letters[ 2 ] ),
        "╲     ╱   ╲     ╱",
        " ╲▁▁▁╱  0  ╲▁▁▁╱ ".gsub( "0", self.letters[ 0 ] ),
        " ╱   ╲     ╱   ╲ ",
        "╱  5  ╲▁▁▁╱  3  ╲".gsub( "5", self.letters[ 5 ] ).gsub( "3", self.letters[ 3 ] ),
        "╲     ╱   ╲     ╱",
        " ╲▁▁▁╱  4  ╲▁▁▁╱ ".gsub( "4", self.letters[ 4 ] ),
        "     ╲     ╱     ",
        "      ╲▁▁▁╱      " ]
    end

    def possible_words
        @@dictionary.select{ | word | word.match?( self.match ) }
    end
    
    def pangrams
        @@dictionary.select{ | word | word.match?( self.pangram ) }
    end

    def shuffle_letters
        self.letters = self.letters[ 0 ] + self.letters[ 1..-1 ].split( "" ).shuffle.join
    end

    def correct?( guess )
        self.possible_words.include?( guess )
    end

    def bonus?( guess )
        self.pangrams.include?( guess )
    end

    def already_guessed?( guess )
        self.guesses.include?( guess )
    end

    def display_puzzle_and_guesses
        result = self.to_s.clone
        guesses_in_columns = self.guesses.each_slice( 12 ).to_a
        guesses_in_columns.each do | column_of_guesses |
            ( 0..11 ).each{ | index | result[ index ] += ( column_of_guesses[ index ].rjust( 16 ) ) if !column_of_guesses[ index ].nil? }
        end
        result
    end

end

# test1 = Puzzle.new( "ecdlmoy" )
# test2 = Puzzle.new( "ogpeham" )
# test3 = Puzzle.new( "rnavmit" )
# test4 = Puzzle.new( "nhitkec" )
# test5 = Puzzle.new( "gcenorv" )
# test6 = Puzzle.new( "shoclma" )
# test7 = Puzzle.new( "cadhinp" )
# test8 = Puzzle.new( "syntdie" )
# test9 = Puzzle.new( "beginkp" )
# test10 = Puzzle.new( "capitvy" )
# test11 = Puzzle.new( "ircnoly" )

# vowels = %w( E A I O U ).shuffle
# common_letters = %w( R T N S L C D P M H G B F ).shuffle
# uncommon_letters = %w( W K V ).shuffle
# rare_letters = %w( X Z J Q ).shuffle

# number_of_vowels = rand( 1..3 )
# number_of_uncommon_letters = rand( 0..2 )
# number_of_rare_letters = [ 0, 0, 0, 0, 1 ].sample
# puzzle = vowels.pop( number_of_vowels )
# puzzle.concat( rare_letters.pop( number_of_rare_letters ) )
# puzzle.concat( common_letters.pop( 6 - ( number_of_vowels + number_of_rare_letters ) ) )
# puzzle.unshift( ( vowels + common_letters ).pop )

words_with_seven_unique_letters = File.open( "seven_unique_letters.txt" ).read.split( "\n" )
random_pangram = words_with_seven_unique_letters.sample.split( "" ).uniq.shuffle
new_puzzle = Puzzle.new( random_pangram.join( "" ) )
points = 0
prompt = TTY::Prompt.new

while true
    system "clear"
    puts new_puzzle.display_puzzle_and_guesses
    puts
    puts "Score: #{ points } points"
    puts "Enter 'S' to shuffle or 'Q' to quit"
    guess = prompt.ask( "Enter a word:" ) do | input |
        input.modify :up
        input.validate( /(?:[sSqQ])|\w{4,}/, "Your guess must have at least 4 letters!" )
        # input.validate( /(?:[sSqQ]{1})|(?=.+#{ new_puzzle.letters[ 0 ] })/, "Your guess must contain the letter '#{ new_puzzle.letters[ 0 ] }'!" )
        # input.validate( Proc.new{ | response | new_puzzle.already_guessed?( response ) }, "You already guessed that word!" )
    end
    case
    when guess == "Q"
        break
    when guess == "S"
        new_puzzle.shuffle_letters
        puts "Shuffling letters..."
    when !guess.include?( new_puzzle.letters[ 0 ] )
        puts "Your guess must contain the letter '#{ new_puzzle.letters[ 0 ] }'!"
    when new_puzzle.already_guessed?( guess )
        puts "You already guessed that word!"
    when new_puzzle.correct?( guess )
        new_puzzle.guesses << guess
        points += new_puzzle.bonus?( guess ) ? 3 : 1
        puts "Correct! +#{ new_puzzle.bonus?( guess ) ? "3 points" : "1 point" }"
    else
        puts "Incorrect - try again!"
    end
    prompt.keypress("(press any key)")
end
puts "Pangrams for this puzzle: #{ new_puzzle.pangrams.join( ", " ) }"

# binding.pry
false

# guess = prompt.ask( "or enter nothing to quit" ) do | input |
#     input.modify :up
#     input.validate( /\S\||\w{4,}/, "Your guess must have at least 4 letters!" )
#     input.validate( "You already guessed that word!", Proc.new{ | response | guesses.include?( response ) }.call( input ) )
#     input.validate( "Your guess must contain the letter '#{ new_puzzle.letters[ 0 ] }'!", Proc.new{ | response | !response.include?( new_puzzle.letters[ 0 ] ) } )
# end