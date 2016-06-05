require 'sinatra/reloader'
require 'sinatra/base'
require 'rubygems'
require 'sinatra/form_helpers'
require 'slim'
require 'pry'
require 'redis'
require 'json'
require 'mock_redis'

require_relative './models/player'
require_relative './models/dealer'
require_relative './models/card_deck'
require_relative './models/card'
require_relative './models/game'
require_relative 'instance_methods'

module BlackJackApp
  class Controller < Sinatra::Base
    include InstanceMethods
    attr_reader :win_lose

    enable :sessions

    helpers Sinatra::FormHelpers
    configure :development do
      register Sinatra::Reloader
    end

    before do
      set_variables
      set_persistence_namespace
    end

    get '/' do
      player.reset_money # TODO: reset player's money not in this action, and only if it's a new session
      slim :start
    end

    get '/game' do
      Game.check_win_conditions
      slim :game
    end

    post '/start_game_set' do
      Game.reset(:all)
      redirect '/set_stake'
    end

    post '/start_round' do
      # TODO BUG - if user clicks 'back' here - he goes to 'set_stake' screen
      # and gets starter cards again - and loses.
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
      redirect '/game_over' unless player.money > 0
      check_enough_cards_left
      Game.reset(:round)

      redirect '/set_stake'
    end

    get '/game_over' do
      # TODO: make a special view here
      slim :game
    end

    get '/no_cards' do
      slim :no_cards
    end

    helpers do
      def button_disabled?(button)
        case button
        when :another_round
          if player.money == 0
            true
          elsif player.win_lose != 'unset'
            nil
          else
            true
          end
        end
      end

      def round_end?
        player.win_lose == 'unset' ? nil : true
      end
    end

    run! if __FILE__ == $PROGRAM_NAME
  end
end
