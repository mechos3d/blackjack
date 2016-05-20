require 'sinatra/reloader'
require 'sinatra/base'
require 'rubygems'
require 'sinatra/form_helpers'
require 'slim'
require 'pry'
require 'redis'
require 'json'

require_relative './models/player'
require_relative './models/dealer'
require_relative './models/card_deck'
require_relative './models/card'

class BlackJackApp < Sinatra::Base
  run! if __FILE__ == $0

  helpers Sinatra::FormHelpers
  configure :development do
    register Sinatra::Reloader
  end

  attr_reader :player, :dealer

  before do
    set_variables
  end

  get '/' do
    # Первоначальный вход
    player.reset_money # TODO - после появления сессий ресетить деньги по условию и не в этом действии (не в get'e)
    slim :start
  end

  get '/game' do
    check_win_conditions
    slim :game
  end

  post '/start_game_set' do
    reset(:game)
    redirect '/set_stake'
  end

  post '/start_round' do
    # если юзер нажмет "назад" - он передходит на страницу set_stake - и может
    # снова начать раунд (ему накидываются еще карты поверх существующих и он
    # проигрывает, и так бесконечно. нужно здесь как-то проверять, находится ли юзер в игре в данный момент (persistence?))
    redirect '/set_stake' if stake_impossible?
    set_stake
    take_initial_cards

    redirect '/game'
  end

  get '/set_stake' do
    set_default_stake_value
    slim :set_stake
  end

  post '/double_stake' do
    player.double_stake
    redirect '/game'
  end

  post '/hit_me' do
    check_enough_cards_left
    player.give_cards(1)

    redirect '/game'
  end

  post '/stand' do
    check_enough_cards_left
    player.stand = 1
    dealer.take_cards_to_score_17

    redirect '/game'
  end

  post '/another_round' do
    redirect '/game_over' if player.money == 0
    check_enough_cards_left
    reset(:round)

    redirect '/set_stake'
  end

  get '/game_over' do
    @win_lose = 'lose'
    @player_no_money_left = true
    slim :game
  end

  get '/no_cards' do
    slim :no_cards
  end

  private

  def check_enough_cards_left
    redirect '/no_cards' if card_deck.not_enough_cards?
  end

  def stake_impossible?
    return true unless params['stake'] && params['stake'].to_i > 0
    params['stake'].to_i > player.money
  end

  def set_variables
    @player = Player.instance
    @dealer = Dealer.instance
  end

  def card_deck
    CardDeck.instance
  end

  def check_win_conditions
    player.stand? ? check_stand_win_condition : check_hit_win_condition
  end

  def check_hit_win_condition
    if player.score > 21
      player_lost
    elsif player.score == 21
      dealer.score == 21 ? player_tie : player_won
    elsif dealer.score == 21
      player_lost
    end
  end

  def check_stand_win_condition
    if dealer.score > 21
      player_won
    elsif player.score > dealer.score
      player_won
    elsif player.score == dealer.score
      player_tie
    else
      player_lost
    end
  end

  def reset(subject = :round)
    [player, dealer].each(&:reset)
    @win_lose = nil
    card_deck.reset if subject == :game
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

  def player_lost
    player.money -= player.stake
    @win_lose = 'lose'
  end

  def player_won
    player.money += player.stake
    @win_lose = 'win'
  end

  def player_tie
    @win_lose = 'tie'
  end

  helpers do
    def button_disabled?(button)
      case button
      when :another_round
        if @player_no_money_left
          true
        elsif @win_lose
          nil
        else
          true
        end
      end
    end
  end

end
