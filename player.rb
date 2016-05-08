require 'singleton'
require 'pry'
require_relative 'subject'

class Player < Subject
  include Singleton

end
