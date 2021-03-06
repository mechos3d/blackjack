module BlackJackApp
  module InstanceMethods
    def check_enough_cards_left
      # gorg TODO: different logic for enough-cards on different stages of the game
      redirect '/no_cards' if card_deck.not_enough_cards?
    end

    def stake_impossible?
      return true unless params['stake'] && params['stake'].to_i > 0
      params['stake'].to_i > player.money
    end

    def set_variables
      player
      dealer
    end

    def player
      @player ||= Player.instance
    end

    def dealer
      @dealer ||= Dealer.instance
    end

    def card_deck
      CardDeck.instance
    end

    def take_initial_cards
      player.give_cards 2
      dealer.give_cards 2
    end

    def set_stake
      player.stake = params['stake'].to_i
    end

    def set_default_stake_value
      @default_stake = player.money >= 50 ? 50 : player.money
    end

    def set_persistence_namespace
      Persistence::Namespace.value = session[:session_id]
    end
  end
end
