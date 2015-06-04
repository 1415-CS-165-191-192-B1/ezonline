require 'spec_helper'
 
feature 'assign tasks', type: :feature do
  
  scenario 'assign' do
    #the google login page sometimes pops up
    #randomly it seems
    
    #sign in to ezonline
    page.visit 'http://ezonline.herokuapp.com/file/show'
    find_by_id('Email').set("ezonline.dev")
    find_by_id('Passwd').set("ezonlinedev")                     
    click_button 'signIn'    
    page.visit 'http://ezonline.herokuapp.com/file/show'
    
    #add google doc assuming sample2x is not yet added
    #to delete the file from ezonline, copy link of assign to users and replace 'assign' with 'delete'
    find_by_id('title_text').set('sample2x')                
    click_on('Add')
    
    #visit the history of the snippet via visiting the link since the button cannot be pressed thru rspec
    page.visit('http://ezonline.herokuapp.com/file/1th41Pd3raUxmZ-FnO_aSF8DG7IQGf9r6Bn4Sp1XM-W4/assign')
    #click on radio button of Dan Garci
    choose 'user_id_112379012271829603650'
    click_button 'Assign'
    click_link 'Log Out'
    print "Press Return to continue..."
    STDIN.getc
    
  end

end
