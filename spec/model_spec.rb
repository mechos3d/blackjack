require File.expand_path '../spec_helper.rb', __FILE__

describe 'BlackJackPlayer' do
  before :each do
    reset_all_data
  end

  it 'counts score' do
    cards1 = [2, 5]
    cards2 = [3, 'A']
    cards3 = [3, 'J', 'A']
    cards4 = [3, 'J', 'Q', 'K']
    cards5 = [2, 3, 4, 5, 6, 7, 8, 9, 10, 'J', 'Q', 'K', 'A']

    expect(score_with(cards1)).to eq 7
    expect(score_with(cards2)).to eq 14
    expect(score_with(cards3)).to eq 14
    expect(score_with(cards4)).to eq 33
    expect(score_with(cards5)).to eq 85
  end

  it 'returns its card instances' do
    arr = [card(5, :clubs), card('Q', :spades)]
    set_cards(player, arr)

    expect(player.cards).to eq arr
  end

  it 'receives random cards' do
    expect(card_deck.cards.size).to eq 52
    expect(player.cards.size).to be_zero
    expect(dealer.cards.size).to be_zero

    player.give_cards(2)
    dealer.give_cards(3)

    expect(player.cards.size).to eq 2
    expect(dealer.cards.size).to eq 3
    expect(card_deck.cards.size).to eq 47
  end
end

describe 'Card' do
  before :each do
    reset_all_data
  end

  it 'returns card\'s value' do
    expect(card(2, :clubs).value).to eq 2
    expect(card(5, :hearts).value).to eq 5
    expect(card('J', :spades).value).to eq 10
    expect(card('K', :diamonds).value).to eq 10
  end

  it 'returns Ace\'s value depending on current sum' do
    ace = card('A', :clubs)
    expect(ace.value).to eq 11
    expect(ace.value(10)).to eq 11
    expect(ace.value(11)).to eq 1
    expect(ace.value(22)).to eq 1
  end
end

describe 'Dealer' do
  before :each do
    reset_all_data
  end

  it 'takes cards until score >= 17' do
    expect(dealer.score).to be_zero
    dealer.take_cards_to_score_17

    expect(dealer.score).to be >= 17
  end
end
