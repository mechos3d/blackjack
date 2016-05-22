require File.expand_path '../spec_helper.rb', __FILE__

describe 'BlackJack Controller' do
  it 'visits the root path' do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include('Start the game')
  end

end

describe 'Contoller_instance_methods' do
  before :each do
    reset_all_data
    player.stake = 300
  end

  context 'player didn\'t click "stand"' do
    it 'player_score < 21, dealer_score < 21' do
      player_score_is 20
      dealer_score_is 18

      expect { Game.check_win_conditions }
        .to_not change { [player.money, player.win_lose] }
    end

    it 'player_score > 21' do
      player_score_is 22
      expect_player_to_lose
    end

    it 'player_score and dealer_score == 21' do
      player_score_is 21
      dealer_score_is 21

      expect_a_tie
    end

    it 'player_score < 21 and dealer_score == 21' do
      player_score_is 20
      dealer_score_is 21

      expect_player_to_lose
    end
  end

  context 'player clicked "stand"' do
    before :each do
      player.stand = 1
      player_score_is 18
    end

    it 'dealer_score < 21 and dealer_score < player_score' do
      dealer_score_is 17
      expect_player_to_win
    end

    it 'dealer_score > 21' do
      dealer_score_is 22
      expect_player_to_win
    end

    it 'dealer_score < 21 and player_score < dealer_score' do
      dealer_score_is 19
      expect_player_to_lose
    end

    it 'dealer_score == 21' do
      dealer_score_is 21
      expect_player_to_lose
    end
  end
end
