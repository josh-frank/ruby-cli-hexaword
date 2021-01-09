require 'pry'

dictionary = File.open( "words.txt" ).read.split( "\r\n" )

unique_letters_per_word = dictionary.zip( dictionary.map{ | word | word.split( "" ).uniq.size } ).to_h

seven_unique_letters = unique_letters_per_word.select{ | word, number_of_unique_letters | number_of_unique_letters == 7 }

File.open( "seven_unique_letters.txt", "w+" ) do | line |
    seven_unique_letters.keys.each { | word | line.puts( word ) }
end

# binding.pry
false