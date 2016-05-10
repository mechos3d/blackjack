require 'singleton'
require 'pry'
require_relative 'black_jack_player'

class Player
  include Singleton
  include BlackJackPlayer

  [:money, :stake, :stand].each do |method_name|
    define_method(method_name) do
      redis.get("#{subject}_#{method_name}")&.to_i || 0
    end

    define_method("#{method_name}=") do |n|
      redis.set "#{subject}_#{method_name}", n
    end
  end

  def double_stake
    self.stake = self.stake*2
  end

  def stand?
    self.stand != 0
  end

  def reset
    redis.pipelined do
      redis.set "#{subject}_stake", 0
      redis.set "#{subject}_cards", [].to_json
      redis.set "#{subject}_score", 0
      redis.set "#{subject}_stand", 0
    end
  end

  def reset_money
    redis.set "#{subject}_money", 1000
  end

end
