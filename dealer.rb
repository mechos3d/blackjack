require 'singleton'
require_relative 'subject'

class Dealer < Subject
  include Singleton

end