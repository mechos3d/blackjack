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

# поставить гем flash и передавать сообщение во флэше
# по окончании игры - флашить данные в редисе (поставить stale время)
# добавить проверки на закончившиеся деньги у игрока
# безопасность - не давать пользователю отправить запрос уже после выигрыша и до ресета (кнопки на вьюхе задизэйблены, но урл он может вбить вручную)

get '/' do
  # Первоначальный вход
  player.reset_money # if ...

  slim :start
end

post '/start_game_set' do
  reset_game
  slim :set_stake
end

post '/start_round' do
  unless params['stake'] && params['stake'].to_i > 0
    # здесь проверка на достаточное количество денег у игрока
    redirect '/set_stake'
  end

  set_stake
  get_initial_cards
  check_win_conditions

  slim :game
end

get '/set_stake' do
  slim :set_stake
end

post '/double_stake' do
  if player.money >= player.stake*2
    player.double_stake
    @stake_doubled = :doubled
  else
    @stake_doubled = :not_doubled
  end

  set_variables
  slim :game
end

post '/hit_me' do
  check_enough_cards_left

  player.give_cards 1
  set_variables
  check_win_conditions

  slim :game
end

post '/stand' do
  check_enough_cards_left

  player.stand = 1
  dealer.get_cards_to_score_17

  check_win_conditions
  slim :game
end

post '/another_round' do
  # здесь тоже нужно проверить деньги игрока и не давать начать новый раунд с сообщением причины на странице

  check_enough_cards_left

  reset_round
  slim :set_stake
end

get '/no_cards' do
  slim :no_cards
end

private

def check_enough_cards_left
  redirect '/no_cards' if card_deck.not_enough_cards?
end

def set_variables
  player; dealer
end

def check_win_conditions
  player.stand? ? check_2nd_win_condition : check_1st_win_condition
end

def reset_game
  [player, dealer, card_deck].each(&:reset)
  @win_lose = nil
end

def reset_round
  [player, dealer].each(&:reset)
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
  elsif player.score == 21 && dealer.score < 21
    player_won
  elsif player.score == 21 && player.score == 21
    player_tie
  elsif dealer.score == 21
    player_lost
  end
end

def check_2nd_win_condition
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
  @player ||= Player.instance
end

def dealer
  @dealer ||= Dealer.instance
end

def card_deck
  CardDeck.instance
end
