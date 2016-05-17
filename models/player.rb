require 'singleton'
require_relative 'black_jack_player'

class Player < BlackJackPlayer
  # include Singleton

  [:money, :stake, :stand].each do |method_name|
    define_method(method_name) do
      get_value("#{subject}.#{method_name}")&.to_i || 0
    end

    define_method("#{method_name}=") do |n|
      set_value("#{subject}.#{method_name}", n)
    end
  end

  def double_stake
    self.stake *= 2
  end

  def stand?
    stand != 0
  end

  def reset
    set_values("#{subject}.stake" => 0,
               "#{subject}.cards" => [],
               "#{subject}.score" => 0,
               "#{subject}.stand" => 0)
  end

  def reset_money
    set_value("#{subject}.money", 1000)
  end
end
