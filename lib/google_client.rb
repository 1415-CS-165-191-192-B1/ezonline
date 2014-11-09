require 'google/api_client'

class GoogleClient 
	@@client = Google::APIClient.new({:application_name => "ezonline",:application_version => "1.0"})
	
	def self.reset	# used to get new client instance
		@@client = Google::APIClient.new({:application_name => "ezonline",:application_version => "1.0"})
		init
	end

	def self.retrieve
		unless @@client
			@@client = Google::APIClient.new(@@client = Google::APIClient.new({:application_name => "ezonline",:application_version => "1.0"}))
			init
		end
		@@client
	end

	def self.init
		@@client.authorization.client_id = GoogleModel.id
		@@client.authorization.client_secret = GoogleModel.secret
		@@client.authorization.scope = GoogleModel.scope
		@@client.authorization.redirect_uri = GoogleModel.uri
	end

	def self.set_access access_token, refresh_token, expires_in, issued_at # initialize client with existing credentials
		@@client.authorization.access_token = access_token 
	    @@client.authorization.refresh_token = refresh_token
	    @@client.authorization.expires_in = expires_in
	    @@client.authorization.issued_at = issued_at
	end

	def self.authorize	# redirect to google login page
		uri = @@client.authorization.authorization_uri
		Launchy.open(uri)
	end

	def self.fetch_token code	# set access token
		@@client.authorization.code = code
		@@client.authorization.fetch_access_token!
	end

	def self.fetch_user	# get authenticated users's credentials
		oauth2 = @@client.discovered_api('oauth2', 'v2')
	  	@@client.execute!(:api_method => oauth2.userinfo.get)
	end

	def self.fetch_file file_title	# get google doc given exact title
		drive = @@client.discovered_api('drive', 'v2')
		@@client.execute(
					api_method: drive.files.list,
					#parameters: {q: %(title = "CS 191 [2] - Project Environment"), maxResults: 1}
					parameters: {q: "title = '" + "#{file_title}" + "'" , maxResults: 1}
				  )
	end

	def self.download_file download_url	# download google doc content
		@@client.execute(uri: download_url)
	end
end