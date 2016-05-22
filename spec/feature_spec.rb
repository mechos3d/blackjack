require File.expand_path '../spec_helper.rb', __FILE__

class CardDeck
  def reset
    value = $deck_stub || Array(0..51).shuffle
    set_value('cards', value)
  end
end

describe 'BlackJack', type: :feature do
  after :each do
    $deck_stub = nil
  end

  it 'capybara test' do
    visit '/'
    expect(page).to have_button 'Start the game'
  end

  it 'Full round - lose scenario' do
    # TODO: would be good to write some helper methods for working with cards ID's more easily
    $deck_stub = [46, 4, 38, 13, 27, 18]
    visit '/'
    click_on 'Start the game'
    expect(player.win_lose).to eq 'unset'
    expect(card_deck.cards.size).to eq 6

    click_on 'Start round'
    expect(card_deck.cards.size).to eq 2
    expect(player.money).to eq 1000
    expect(player.stake).to eq 50

    expect(player.send(:cards_array)).to match [46, 4]
    expect(player.score).to eq 15

    expect(dealer.send(:cards_array)).to match [38, 13]
    expect(dealer.score).to eq 13

    click_on 'Hit'
    expect(player.send(:cards_array)).to match [46, 4, 27]
    expect(player.score).to eq 18
    expect(card_deck.cards.size).to eq 1

    click_on 'Double the stake'
    expect(player.stake).to eq 100

    click_on 'Stand'
    expect(dealer.score).to eq 20
    expect(player.win_lose).to eq 'lose'
    expect(player.money).to eq 900
    expect(card_deck.cards.size).to eq 0
  end

  it 'Full round - win scenario' do
    $deck_stub = [17, 7, 1, 34, 42, 49]
    visit '/'
    click_on 'Start the game'

    click_on 'Start round'

    expect(player.send(:cards_array)).to match [17, 7]
    expect(player.score).to eq 15

    expect(dealer.send(:cards_array)).to match [1, 34]
    expect(dealer.score).to eq 13

    click_on 'Hit'
    expect(player.send(:cards_array)).to match [17, 7, 42]
    expect(player.score).to eq 20

    click_on 'Stand'
    expect(dealer.score).to eq 23
    expect(dealer.send(:cards_array)).to match [1, 34, 49]

    expect(player.win_lose).to eq 'win'
    expect(player.money).to eq 1050
    expect(card_deck.cards.size).to eq 0
  end

  it 'Full round - tie scenario' do
    $deck_stub = [8, 3, 2, 3, 16, 26, 28, 29, 55]
    visit '/'
    click_on 'Start the game'

    click_on 'Start round'

    expect(player.send(:cards_array)).to match [8, 3]
    expect(player.score).to eq 15

    expect(dealer.send(:cards_array)).to match [2, 3]
    expect(dealer.score).to eq 9

    click_on 'Hit'
    expect(player.send(:cards_array)).to match [8, 3, 16]
    expect(player.score).to eq 20

    click_on 'Stand'
    expect(dealer.score).to eq 20
    expect(dealer.send(:cards_array)).to match [2, 3, 26, 28, 29]

    expect(player.win_lose).to eq 'tie'
    expect(player.money).to eq 1000
    expect(card_deck.cards.size).to eq 1
  end
end
