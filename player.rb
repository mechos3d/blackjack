require 'singleton'
require 'pry'
require_relative 'black_jack_player'

class Player
  include Singleton
  include BlackJackPlayer

  [:money, :stake].each do |method_name|
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

end
