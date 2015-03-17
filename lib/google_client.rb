require 'google/api_client'

class GoogleClient 
	@@client = Google::APIClient.new({:application_name => "ezonline",:application_version => "1.0"})
	
	def self.reset	# used to reset client instance
		@@client = Google::APIClient.new({:application_name => "ezonline",:application_version => "1.0"})
		init
	end

	def self.retrieve
		unless @@client
			@@client = Google::APIClient.new({:application_name => "ezonline", :application_version => "1.0"})
			init
		end
		@@client
	end

	def self.init
		@@client.authorization.client_id = GoogleModel::ID
		@@client.authorization.client_secret = GoogleModel::SECRET
		@@client.authorization.scope = GoogleModel::SCOPE
		@@client.authorization.redirect_uri = GoogleModel::URI
	end

	def self.set_access access_token, refresh_token, expires_in, issued_at # initialize client with existing credentials
		@@client.authorization.access_token = access_token 
	    @@client.authorization.refresh_token = refresh_token
	    @@client.authorization.expires_in = expires_in
	    @@client.authorization.issued_at = issued_at
	end

	def self.authorize	# redirect to google login page
		uri = build_auth_uri
		Launchy.open(uri)
	end

	def self.build_auth_uri
		return @@client.authorization.authorization_uri(:approval_prompt => :auto).to_s 
	end

	def self.fetch_token code	# set access token
		@@client.authorization.code = code
		@@client.authorization.fetch_access_token!
	end

	def self.get_auth
		@@client.authorization
	end

	def self.refresh_token
	    #auth = @@client.authorization
		#auth.client_id = GoogleModel::ID
		#auth.client_secret = GoogleModel::SECRET
		#auth.grant_type = 'refresh_token'
	    #auth.refresh!
	    refresh_token = @@client.authorization.refresh_token

	    client = Google::APIClient.new({:application_name => "ezonline",:application_version => "1.0"})
	  	client.authorization.client_id = GoogleModel::ID
	  	client.authorization.client_secret = GoogleModel::SECRET
	  	client.authorization.grant_type = 'refresh_token'
	  	client.authorization.refresh_token = refresh_token

	  	client.authorization.fetch_access_token!
	  	@@client = client  	
	end

	def self.fetch_user	# get authenticated users's credentials
		oauth2 = @@client.discovered_api('oauth2', 'v2')
	  	@@client.execute!(:api_method => oauth2.userinfo.get)
	end

	def self.fetch_file file_title	# get google doc given exact title
		drive = @@client.discovered_api('drive', 'v2')
		@@client.execute(
			api_method: drive.files.list,
			parameters: {q: "title = '" + "#{file_title}" + "'" , maxResults: 1, trashed: false})
	end

	def self.download_file download_url	# download google doc content
		@@client.execute(uri: download_url)
	end

	def self.upload tmp, title
	    media = Google::APIClient::UploadIO.new(tmp, 'text/plain', title + '.txt')
	    drive = @@client.discovered_api('drive', 'v2')
        file = drive.files.insert.request_schema.new({
          'title' => title,
          'description' => 'Compiled',
          'mimeType' => 'text/plain'
        })
        @@client.execute(
          :api_method => drive.files.insert,
          :body_object => file,
          :media => media,
          :parameters => {
            'uploadType' => 'multipart',
            'convert' => true,
            'alt' => 'json'})
    end

end