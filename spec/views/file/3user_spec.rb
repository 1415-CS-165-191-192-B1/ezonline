require 'spec_helper'
 
feature 'user login', type: :feature do

  
  scenario 'employee view' do
    page.visit 'http://ezonline.herokuapp.com'
  	
    #sign into ezonline
    click_link 'Log In'
    find_by_id('Email').set("hazelnutharry123")
    find_by_id('Passwd').set("yellowcard123")
    click_button 'signIn'
  	
    #task list is shown once the user is signed in

    #visit page of assigned snippet since couldn't use rspec to click on assigned task
  	visit 'http://ezonline.herokuapp.com/file/16/history?'
  	
    #edit the assigned snippet
    click_button 'Edit'
  	find_by_id('text_commit_text').set('new commit')
  	click_button 'Save'
    
  end

end
