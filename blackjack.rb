require 'sinatra/reloader'
require 'sinatra/base'

require 'rubygems'
require 'sinatra/form_helpers'
require 'slim'

require 'pry'
require 'redis'
require 'json'

require_relative 'player'
require_relative 'dealer'
require_relative 'card_deck'
require_relative 'card'

class BlackJackApp < Sinatra::Base
  helpers Sinatra::FormHelpers
  configure :development do
    register Sinatra::Reloader
  end
  # make before_filter with 'set_variables'

  get '/' do
    # Первоначальный вход
    player.reset_money # if ...

    slim :start
  end

  post '/start_game_set' do
    reset_game
    set_default_stake_value

    slim :set_stake
  end

  post '/start_round' do
    redirect '/set_stake' unless params['stake'] && params['stake'].to_i > 0
    if params['stake'].to_i > player.money
      # set flash message
      redirect '/set_stake'
    end

    set_stake
    take_initial_cards
    check_win_conditions

    set_variables
    slim :game
  end

  get '/set_stake' do
    set_default_stake_value
    slim :set_stake
  end

  post '/double_stake' do
    if player.money >= player.stake * 2
      player.double_stake
      @stake_doubled = :doubled
    else
      @stake_doubled = :not_enough_money
    end

    set_variables
    slim :game
  end

  post '/hit_me' do
    check_enough_cards_left

    player.give_cards 1
    check_win_conditions

    set_variables
    slim :game
  end

  post '/stand' do
    check_enough_cards_left

    player.stand = 1
    dealer.take_cards_to_score_17
    check_win_conditions

    set_variables
    slim :game
  end

  post '/another_round' do
    if player.money == 0
      # set_flash_message
      @win_lose = 'lose'
      @player_no_money_left = true

      set_variables
      slim :game
    else

      check_enough_cards_left
      reset_round

      redirect '/set_stake'
    end
  end

  get '/no_cards' do
    slim :no_cards
  end

  private

  def check_enough_cards_left
    redirect '/no_cards' if card_deck.not_enough_cards?
  end

  def set_variables
    player
    dealer
  end

  def check_win_conditions
    player.stand? ? check_stand_win_condition : check_hit_win_condition
  end

  def reset_game
    [player, dealer, card_deck].each(&:reset)
    @win_lose = nil
  end

  def reset_round
    [player, dealer].each(&:reset)
    @win_lose = nil
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

  def player
    @player = Player.instance
  end

  def dealer
    @dealer = Dealer.instance
  end

  def card_deck
    CardDeck.instance
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