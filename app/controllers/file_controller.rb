require 'google_client'
require 'file_parser'

class FileController < ApplicationController
  before_filter :authenticate_admin

  @@snippet_id = 0
  
  def fetch
    search_result = GoogleClient::fetch_file "CS 191 [2] - Project Environment"
    if search_result.status == 200
      file = search_result.data['items'].first
      download_url = file['exportLinks']['text/plain'] # docs do not have 'downloadUrl' 
      if download_url
        result = GoogleClient::download_file download_url
        if result.status == 200
          @message = FileParser::parse result, file.id, file.title, session[:user_id]
        else # result.status != 200
          @message = "An error occurred: #{result.data['error']['message']}"
        end
      end
    end
  end

  def show
  	@snippets = Snippet.all
  end

  def edit
  	@@snippet_id = params[:id]
  	snippet = Snippet.find(@@snippet_id)
  	@title = snippet.title
  	@commit = Commit.where(snippet_id: params[:id]).last!
  	user = User.find(@commit.user_id)
  	@username = user.username
  end

  def update
  	commit = Commit.new
  	commit.user_id = session[:user_id]
  	commit.snippet_id = @@snippet_id
  	commit.commit_text = params[:text][:commit_text]
  	commit.save!
  end

end
