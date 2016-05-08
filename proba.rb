require 'sinatra/reloader' # You may want to set environment variable to development and conditionally load the gem
require 'sinatra'
require 'pry'
require 'redis'
require 'json'

require_relative 'player'
require_relative 'dealer'
require_relative 'card_deck'
require_relative 'card'

# по окончании игры - флашить данные в редисе


get '/' do
  binding.pry
  # Первоначальный вход
  slim :start
end

get '/game' do
  set_player_instances

  slim :game
end

post '/start' do
  set_player_and_dealer
  initialize_data
  get_initial_cards

  redirect '/game'
end

post '/double_stake' do
  # Поднять ставку, больше ничего не менять (в будущем сделать Ajax'ом)
  stake = redis.get 'current_stake'
  redis.set 'current_stake', stake.to_i*2

  redirect '/game'
end

post '/hit_me' do
  user_cards = JSON.parse redis.get('user_cards')
  user_cards += card_deck.get_cards!(1)
  redis.set 'user_cards', user_cards
  binding.pry
  # Дать пользовтелю карту,
  # Проверить условия выигрыша
  # Если условие выполнилось - отобразить кнопку play-again

  redirect '/game'
end

post '/stand' do
  # Дилер берет карты одну-за-другой, пока не достигнет условия выигрыша.
  # На вьюшке сделать бы поочередное появление этих карт, чтобы карты появились не моментально сразу все
  # После этого появляется кнопка play-again

  redirect '/game'
end

post '/play-again' do
  # следующая партия

  slim :game
end

post '/reset' do
  # тестовое действие
  initialize_data
  get_initial_cards

  redirect '/game'
end

private

def set_player_and_dealer
  @player = Player.instance
  @dealer = Dealer.instance
end

def calculate_score(var)
  cards = instance_variable_get(var)
  cards.inject(0) { |sum, i| sum += i.value }
end

def initialize_data
  # инициализация партии
  player
  redis.pipelined do
    redis.set 'user_money', 1000
    redis.set 'current_stake', 100 # TODO заглушка
    ['user_cards', 'dealer_cards', 'user_score', 'dealer_score']
      .each { |a| redis.set a, 0 }
    redis.set('proba', [1,2,3,4].to_json)
  end
end

def get_initial_cards
  redis.set 'dealer_cards', card_deck.get_cards!(2).to_json
  redis.set 'user_cards', card_deck.get_cards!(2).to_json
end

def check_win_condition

end


def card_deck
  CardDeck.instance
end

# def redis
#   @redis ||= Redis.new
# end

# get '/hello/:name' do
#   # matches "GET /hello/foo" and "GET /hello/bar"
#   # params['name'] is 'foo' or 'bar'
#   "Hello #{params['name']}!"
# end