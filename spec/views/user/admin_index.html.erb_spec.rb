describe 'user/admin_index.html.erb' do
	it 'shows all the notifs to the current admin' do
	  expect(response).to redirect_to '/login'
	end
end