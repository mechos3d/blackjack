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
        player.lose
      elsif player.score == 21
        dealer.score == 21 ? player.tie : player.win
      elsif dealer.score == 21
        player.lose
      end
    end

    def check_stand_win_condition
      if dealer.score > 21 || player.score > dealer.score
        player.win
      elsif player.score == dealer.score
        player.tie
      else
        player.lose
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
