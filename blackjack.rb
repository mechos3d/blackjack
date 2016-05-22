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
    # TODO: условия win_lose переделаны - теперь это не @win_lose,
    # а player.win_lose - но вьюхи еще не поменял
    attr_reader :win_lose

    helpers Sinatra::FormHelpers
    configure :development do
      register Sinatra::Reloader
    end

    before do
      set_variables
    end

    get '/' do
      # Первоначальный вход
      player.reset_money # TODO: после появления сессий ресетить деньги
      # по условию и не в этом действии (не в get'e)
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
      # если юзер нажмет "назад" - он передходит на страницу set_stake -
      # и может снова начать раунд (ему накидываются еще карты поверх
      # существующих и он проигрывает, и так бесконечно. нужно здесь
      # как-то проверять, находится ли юзер в игре в данный момент
      # (persistence?))
      redirect '/set_stake' if stake_impossible?
      puts card_deck.cards.to_s
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
      # TODO: сделать здесь другую вьюшку
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
