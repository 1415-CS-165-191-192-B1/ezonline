require 'spec_helper'
 
feature 'user login', type: :feature do

  
  scenario 'employee view' do
  page.visit 'http://ezonline.herokuapp.com'
  	click_link 'Log In'
  #	print "Press Return to continue..."
  #  STDIN.getc
    find_by_id('Email').set("hazelnutharry123")
    find_by_id('Passwd').set("yellowcard123")
    click_button 'signIn'
  	print "Press Return to continue..."
    STDIN.getc
  #  first('.button_to').click_button(:value => 'Show History')
  	visit 'http://ezonline.herokuapp.com/file/16/history?'
  	#click_button 'Show History'
  	click_button 'Edit'
  	print "Press Return to continue..."

  	find_by_id('text_commit_text').set('new commit')
  	click_button 'Save'
    STDIN.getc

   # expect(page).to have_text("Dashboard")    
 #   click_link 'Log Out'
  #  expect(page).to have_text("You have successfully logged out.")
  end

end
#login_spec.rb