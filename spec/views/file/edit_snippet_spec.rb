require 'spec_helper'

feature 'User edits a snippet' do
  scenario 'they see the foobar on the page' do
    visit 'http://ezonline.herokuapp.com/file/21/edit'

    fill_in 'text_commit_text', with: 'My foobar'
    click_button 'Save'

    expect(page).to have_text 'Update saved'
  end
end
