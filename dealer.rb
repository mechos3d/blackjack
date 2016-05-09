require 'singleton'
require_relative 'black_jack_player'

class Dealer
  include Singleton
  include BlackJackPlayer

  def get_cards_to_score_17
    while self.score < 17 do
      give_cards 1
    end
  end

end