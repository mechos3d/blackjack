require 'sinatra/reloader' # You may want to set environment variable to development and conditionally load the gem
require 'sinatra'

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

# по окончании игры - флашить данные в редисе
# ничья сейчас не реализована. Равный счет считается проигрышем игрока
# не реализована первоначальная ставка
# реализовать проверку на достаточное кол-во карт в колоде
# (игра заканчивается когда: либо закончились деньги у пользователя, либо кончились карты в колоде)

get '/' do
  # Первоначальный вход
  slim :start
end

get '/game' do # Win или lose - Лучше показывать сразу на этой же вьюхе.
  player; dealer

  slim :game
end

post '/start' do
  unless params['stake'] && params['stake'].to_i > 0
    # поставить гем flash и передавать сообщение во флэше
    redirect '/'
  end

  reset_game
  get_initial_cards
  set_stake

  redirect '/game'
end

post '/double_stake' do
  #(в будущем сделать Ajax'ом)
  player.double_stake

  redirect '/game'
end

post '/hit_me' do
  player.give_cards 1
  check_1st_win_condition

  redirect '/game'
end

post '/stand' do
  dealer.get_cards_to_score_17
  check_2nd_win_condition

  redirect '/game'
end

post '/another_round' do
  # TODO - проверка на количество доступных карт в колоде
  reset_round
  get_initial_cards
  set_stake # о ставке пользователя нужно снова спрашивать, как в самом начале
  # поэтому здесь возможно редирект не на game

  slim :game
end

post '/reset' do
  # тестовое действие
  reset_game
  get_initial_cards

  redirect '/game'
end

get '/lose' do
  @win_lose = 'lose'
  player; dealer

  slim :game
end

get '/win' do
  @win_lose = 'win'
  player; dealer

  slim :game
end

private

def reset_game
  player.reset(reset_money: true)
  dealer.reset
  card_deck.reset
  # set_stake
  @win_lose = nil
end

def reset_round
  player.reset(reset_money: false)
  dealer.reset
  # set_stake
  @win_lose = nil
end

def get_initial_cards
  player.give_cards 2
  dealer.give_cards 2
end

def set_stake
  player.stake = params['stake'].to_i
end

def check_1st_win_condition
  if player.score > 21
    player_lost
  elsif player.score == 21
    player_won
  end
end

def check_2nd_win_condition
  if dealer.score > 21
    player_won
  elsif player.score > dealer.score
    player_won
  else
    player_lost
  end
end

def player_lost
  player.money -= player.stake

  redirect '/lose'
end

def player_won
  player.money += player.stake

  redirect '/win'
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
