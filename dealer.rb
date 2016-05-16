require 'singleton'
require_relative 'black_jack_player'

class Dealer
  include Singleton
  include BlackJackPlayer

  def take_cards_to_score_17
    give_cards(1) while score < 17
  end
end
