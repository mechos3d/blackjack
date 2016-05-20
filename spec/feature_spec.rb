require File.expand_path '../spec_helper.rb', __FILE__

describe 'BlackJack', type: :feature do

  it 'capybara test' do
    visit '/'
    expect(page).to have_button 'Start the game'
  end

end
