require 'google_client'
require 'vimeo_client'
require 'file_parser'
require 'tempfile'


class FileController < ApplicationController
  before_filter :authenticate_admin, :only => [:new, :fetch, :compile]
  before_filter :check_login_state, :only => [:show]
  

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
        @message = "Sorry, EZ Online cannot find a Google Doc with that title."
      end # end unless

    end
    
  end

  def show
  	snippets = Snippet.all
    docs = Doc.all
    @files = Hash.new

    docs.each do |d|
      title = d.read_attribute('docname')
      id = d.read_attribute('doc_id')
      @files[title] = Snippet.where(doc_id: id)
    end
    
    p @files

  end

  def history
    @commits = Commit.where(snippet_id: params[:format])
    @snippet = Snippet.find(params[:format])
  end

  def edit
    @commit = Commit.find(params[:id])
  	snippet = Snippet.find(@commit.snippet_id)
  	@title = snippet.title
    @video_id = snippet.video_id
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

  def compile
    doc = Doc.find_by docname: params[:id]
    doc_id = doc.read_attribute('doc_id')
    snippets = Snippet.where(doc_id: doc_id)

    result = Hash.new
    snippets.each do |s|
      result[s.title] = Commit.where(id: s.id)
                              .order(created_at: :desc)
                              .first
                              .commit_text
    end

    tmp = Tempfile.new(params[:id], Rails.root.join('tmp'))
    begin
      result.each do |title, text|
        tmp.write(title.upcase)
        tmp.write(text)
      end

      result = GoogleClient::upload tmp, params[:id]
      if result.status == 200
        return result.data
      else
        puts "An error occurred: #{result.data['error']['message']}"
        return nil
      end
    ensure
      tmp.close
      tmp.unlink
    end

    #Snippet.select("DISTINCT(snippet_id)")
    #       .where(doc_id: doc_id)
    #       .merge(Snippet.group("snippet_id")
    #                     .order("created_at DESC"))

    #latest = Snippet.joins(:commits)
    #                .select('commits.commit_text AS commit_text')
    #                .where(doc_id: doc_id)
    #                .maximum(:created_at, :group => snippet_id)  
    #p latest.first.commit_text
    #result = []
    #latest.each_pair do |t, p|  
    #  result << Table.find(:first, :conditions => ["type = ? and price = ?", t, p])
  end

end
