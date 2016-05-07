require 'singleton'

class CardDeck
  include Singleton

  attr_reader :cards

  def initialize
    fill_deck
  end

  def get_card
    #
  end

  private

  def fill_deck
    [:clubs, :diamonds, :hearts, :spades].each do |suit|
      [2,3,4,5,6,7,8,9,10,'J','Q','K','A'].each do |face|
        @cards ||= []
        @cards << Card.new(suit: suit, face: face)
      end
    end

  end

end
