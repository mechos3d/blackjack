require 'singleton'

class Player
  include Singleton

  attr_reader :money
  attr_reader :cards


  def initialize
    @money = 1000
  end

end
