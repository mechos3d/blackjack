require 'singleton'
require_relative 'black_jack_player'

class Player < BlackJackPlayer
  [:money, :stake, :stand, :stake_state, :win_lose].each do |var|
    if [:stake_state, :win_lose].include?(var)
      define_method(var) do
        get_value("#{subject}.#{var}") || 0
      end
    else
      define_method(var) do
        get_value("#{subject}.#{var}")&.to_i || 0
      end
    end

    define_method("#{var}=") do |n|
      set_value("#{subject}.#{var}", n)
    end
  end

  def double_stake
    if money > stake * 2
      self.stake *= 2
      self.stake_state = 'doubled'
    else
      self.stake_state = 'not_enough_money'
    end
  end

  def stand?
    stand != 0
  end

  def reset
    set_values("#{subject}.stake" => 0,
               "#{subject}.cards" => [],
               "#{subject}.score" => 0,
               "#{subject}.stand" => 0,
               "#{subject}.stake_state" => 'unset',
               "#{subject}.win_lose" => 'unset')
  end

  def reset_money
    set_value("#{subject}.money", 1000)
  end

  def lose
    self.money -= stake
    self.win_lose = 'lose'
  end

  def win
    self.money += stake
    self.win_lose = 'win'
  end

  def tie
    self.win_lose = 'tie'
  end
end
