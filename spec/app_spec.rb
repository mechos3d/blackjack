require File.expand_path '../spec_helper.rb', __FILE__
require 'pry'

describe 'My Sinatra Application' do
  it 'should allow accessing the home page' do
    get '/'

    expect(last_response).to be_ok
  end
end


# describe 'proba' do
#   it 'some random file test' do
#     proba = Proba.new
#     expect(proba.met).to eq 5
#   end
# end

describe 'BlackJack', type: :feature do
  # before :each do
  #   User.make(:email => 'user@example.com', :password => 'password')
  # end

  it 'capybara test' do
    visit '/'
    # within("#session") do
    #   fill_in 'Email', :with => 'user@example.com'
    #   fill_in 'Password', :with => 'password'
    # end
    # click_button 'Sign in'
    expect(page).to have_button 'Start the game'
  end
end
