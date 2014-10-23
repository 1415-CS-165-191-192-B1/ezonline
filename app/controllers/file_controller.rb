require 'google_client'
require 'file_parser'

class FileController < ApplicationController
	before_filter :authenticate_user

	def get
		search_result = GoogleClient::fetch_file "CS 191 [2] - Project Environment"
		if search_result.status == 200
			file = search_result.data['items'].first
			download_url = file['exportLinks']['text/plain'] # docs do not have 'downloadUrl'	
			if download_url
				result = GoogleClient::download_file download_url
				if result.status == 200
					@message = FileParser::parse result, file.id, file.title, session[:user_id]
				else # result.status != 200
					puts "An error occurred: #{result.data['error']['message']}"
				end
			end
		end
	end

end
