require 'spec_helper'
 
feature 'try to visit google login', type: :feature do

  
  scenario 'try to access heroku' do
  page.visit 'http://ezonline.herokuapp.com'
  click_link 'Log In'
    find_by_id('Email').set("ezonline.dev")
    find_by_id('Passwd').set("ezonlinedev")
    click_button 'signIn'
    expect(page).to have_text("Dashboard")    
    click_link 'Log Out'
    expect(page).to have_text("You have successfully logged out.")
  end

end
#login_spec.rb