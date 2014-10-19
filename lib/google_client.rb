require 'google/api_client'

module GoogleClient 
	@@client = Google::APIClient.new({:application_name => "ezonline",:application_version => "1.0"})

	def self.init
		@@client.authorization.client_id = GoogleModel.id
		@@client.authorization.client_secret = GoogleModel.secret
		@@client.authorization.scope = GoogleModel.scope
		@@client.authorization.redirect_uri = GoogleModel.uri
	end

	def self.authorize
		uri = @@client.authorization.authorization_uri
		Launchy.open(uri)
	end

	def self.set_code code
		@@client.authorization.code = code
	end

	def self.fetch_token
		@@client.authorization.fetch_access_token!
	end

	def self.fetch_user
		oauth2 = @@client.discovered_api('oauth2', 'v2')
	  	@@client.execute!(:api_method => oauth2.userinfo.get)
	end

	def self.fetch_file file_title
		drive = @@client.discovered_api('drive', 'v2')
		@@client.execute(
					api_method: drive.files.list,
					#parameters: {q: %(title = "CS 191 [2] - Project Environment"), maxResults: 1}
					parameters: {q: "title = '" + "#{file_title}" + "'" , maxResults: 1}
				  )
	end

	def self.download_file download_url
		@@client.execute(uri: download_url)
	end
end