def reset_all_data
  [card_deck, player, dealer].each(&:reset)
  player.reset_money
end

def card(face, suit)
  Card.new(face: face, suit: suit)
end

def dealer
  Dealer.instance
end

def player
  Player.instance
end

def card_deck
  CardDeck.instance
end

def set_cards(subject, cards)
  arr = cards.map { |i| card_deck_index(card(i.face, i.suit)) }
  subject.send(:cards_array=, arr)
end

def score_with(cards)
  cards.map! { |i| Card.new(face: i, suit: :clubs) }
  set_cards(player, cards)
  player.score
end

def card_deck_index(card)
  CardDeck::CARD_INSTANCES.find_index { |dc| dc == card }
end

def expect_player_to_win
  expect { Game.check_win_conditions }
    .to change { [player.money, player.win_lose] }
    .from([1000, 'unset'])
    .to([1300, 'win'])
end

def expect_player_to_lose
  expect { Game.check_win_conditions }
    .to change { [player.money, player.win_lose] }
    .from([1000, 'unset'])
    .to([700, 'lose'])
end

def expect_a_tie
  expect { Game.check_win_conditions }
    .to change { [player.money, player.win_lose] }
    .from([1000, 'unset'])
    .to([1000, 'tie'])
end

def player_score_is(n)
  set_score(player, n)
end

def dealer_score_is(n)
  set_score(dealer, n)
end

def set_score(subject, n)
  tens = n / 10
  remainder = n % 10
  arr =
    case remainder
    when 1
       [card(10, :clubs)] * (tens - 1) + [card(2, :clubs), card(9, :clubs)]
    when 0
      [card(10, :clubs)] * tens
    else
      [card(10, :clubs)] * tens + [card(remainder, :clubs)]
    end
  set_cards(subject, arr)
end
