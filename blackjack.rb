# myapp.rb
require 'sinatra'
require 'sinatra/reloader'

get '/' do
	@var1 = 'proba1'
	@var2 = 'proba2'

  slim :index
end

get '/hello/:name' do
  # matches "GET /hello/foo" and "GET /hello/bar"
  # params['name'] is 'foo' or 'bar'
  "Hello #{params['name']}!"
end


class Ttt

  def initialize
  	
  end

  def met
  	2
  end

end