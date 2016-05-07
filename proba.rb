# myapp.rb
require 'sinatra/reloader'
require 'sinatra'
require 'pry'
require 'redis'
require 'json'

require_relative 'player'
require_relative 'dealer'
require_relative 'card_deck'
require_relative 'card'


redis = Redis.new

get '/' do
  # Первоначальный вход
  # binding.pry
  initialize_data

  @card_deck = CardDeck.instance
  @player = Player.instance
  @dealer = Dealer.instance

  slim :index
end

get 'start' do
  # инициализация партии -
  # ставка, деньги пользователя, данные колоды и дилера - запись в редис под опред.ключом
  initialize_data

  @card_deck = CardDeck.instance
  @player = Player.instance
  @dealer = Dealer.instance

  slim :index
end

# переделать все эти геты на посты
get '/raise' do
  # Поднять ставку, больше ничего не менять (в будущем сделать Ajax'ом)
  @card_deck = redis.get 'user_score'
  @player = JSON.parse(redis.get('proba'))
  @dealer = Dealer.instance

  slim :index
end

# переделать все эти геты на посты
get '/hit_me' do
  # Дать пользовтелю карту,
  # Проверить условия выигрыша
  # Если условие выполнилось - отобразить кнопку play-again
  @var1 = "Hit !"

  slim :index
end

# переделать все эти геты на посты
get '/stand' do
  # Дилер берет карты одну-за-другой, пока не достигнет условия выигрыша.
  # На вьюшке сделать бы поочередное появление этих карт, чтобы карты появились не моментально сразу все
  # После этого появляется кнопка play-again
  @var1 = "Stand !"

  slim :index
end

# переделать все эти геты на посты
get '/play-again' do
  # следующая партия
  @var1 = "Play_again !"

  slim :index
end

# переделать все эти геты на посты
get 'reset' do
  # тестовое действие

  slim :index
end


def initialize_data
  redis = Redis.new

  redis.pipelined do
    redis.set 'user_money', 1000
    ['stake', 'user_cards','dealer_cards', 'user_score', 'dealer_score']
      .each { |a| redis.set a, 0 }
    redis.set('proba', [1,2,3,4].to_json)
  end
end
# get '/hello/:name' do
#   # matches "GET /hello/foo" and "GET /hello/bar"
#   # params['name'] is 'foo' or 'bar'
#   "Hello #{params['name']}!"
# end