require 'securerandom'

class Roller
  def self.roll(expression) #Rolls to be used in play and creation
    number_of_dice, sides = expression.split('d').map(&:to_i) #split input text to assign first number to dice total and latter number to denote sides
    results = Array.new(number_of_dice) { SecureRandom.random_number(1..sides) }
    total = results.sum
    return results, total
  end
end