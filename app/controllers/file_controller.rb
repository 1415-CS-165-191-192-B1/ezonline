require 'google_client'
require 'file_parser'

class FileController < ApplicationController
  before_filter :authenticate_admin

  def new
  end
  
  def fetch
    search_result = GoogleClient::fetch_file params[:title][:text]
    if search_result.status == 200
      file = search_result.data['items'].first
      unless file.nil?
        download_url = file['exportLinks']['text/plain'] # docs do not have 'downloadUrl' 
        if download_url
          result = GoogleClient::download_file download_url
          if result.status == 200
            @message = FileParser::parse result, file.id, file.title, session[:user_id]
          else # result.status != 200
            @message = "An error occurred: #{result.data['error']['message']}"
          end
        end

      else
        @message = "Cannot find document with title"
      end # end unless
    end
  end

  def show
  	@snippets = Snippet.all
  end

  def history
    @commits = Commit.where(snippet_id: params[:format])
    @snippet = Snippet.find(params[:format])
  end

  def edit
    @commit = Commit.find(params[:id])
  	snippet = Snippet.find(@commit.snippet_id)
  	@title = snippet.title
  	user = User.find(@commit.user_id)
  	@username = user.username
  end

  def update
  	commit = Commit.new
  	commit.user_id = session[:user_id]
  	commit.snippet_id = params[:snippet_id]
  	commit.commit_text = params[:text][:commit_text]
  	commit.save!
  end

end
