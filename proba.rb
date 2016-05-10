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

# по окончании игры - флашить данные в редисе (поставить stale время)
# добавить проверки на закончившиеся деньги у игрока
# скрыть на вьюхе счет дилера и одну карту. Показываем всё это только после выигрыша-проигрыша
# безопасность - не давать пользователю отправить запрос уже после выигрыша и до ресета (кнопки на вьюхе задизэйблены, но урл он может вбить вручную)

get '/' do
  # Первоначальный вход
  reset_game
  player.reset_money

  slim :start
end

get '/set_stake' do
  slim :set_stake
end

get '/game' do
  player; dealer
  @player.stand? ? check_2nd_win_condition : check_1st_win_condition
  
  slim :game
end

post '/start' do
  unless params['stake'] && params['stake'].to_i > 0
    # поставить гем flash и передавать сообщение во флэше
    redirect '/set_stake'
  end

  get_initial_cards
  set_stake
  redirect '/game'
end

post '/double_stake' do  #(в будущем сделать Ajax'ом)
  player.double_stake
  dealer
  @stake_doubled = true
  slim :game
end

post '/hit_me' do  #(в будущем сделать Ajax'ом)
  # здесь тоже сделать проверку на количество карт
  player.give_cards 1
  redirect '/game' # может это сделать везде не редиректом, а просто вызовом метода ?
end

post '/stand' do
  # здесь тоже сделать проверку на количество карт
  player.stand = 1
  dealer.get_cards_to_score_17
  redirect '/game'
end

post '/another_round' do
  if card_deck.not_enough_cards?
    slim :no_cards 
  else
    reset_round
    redirect '/set_stake'
  end
end

private

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
