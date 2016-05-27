class Game
  class << self
    def reset(subject = :round)
      [player, dealer].each(&:reset)
      player.win_lose = 'unset'
      card_deck.reset if subject == :all
    end

    def check_win_conditions
      player.stand? ? check_stand_win_condition : check_hit_win_condition
    end

    def check_hit_win_condition
      if player.score > 21
        :lose
      elsif player.score == 21
        dealer.score == 21 ? :tie : :win
      elsif dealer.score == 21
        :lose
      end
    end

    def check_stand_win_condition
      if dealer.score > 21 || player.score > dealer.score
        :win
      elsif player.score == dealer.score
        :tie
      else
        :lose
      end
    end

    def card_deck
      CardDeck.instance
    end

    def player
      Player.instance
    end

    def dealer
      Dealer.instance
    end
  end
end
