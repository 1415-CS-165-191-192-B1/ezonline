require 'google_client'
require 'vimeo_client'
require 'file_parser'
require 'tempfile'


class FileController < ApplicationController
  before_filter :authenticate_admin, :only => [:new, :fetch, :compile]
  before_filter :check_login_state, :only => [:show]
  before_filter :check_vlogin_state, :only => [:fetch_video, :fetch_videos]

  def new
  end
  
  def fetch
    #squish: remove whitespaces from both ends, compress multiple to one, blank: check if nil or whitespaces
    search_result = GoogleClient::fetch_file params[:title][:text].squish unless params[:title][:text].blank?

    if search_result.status == 200
      file = search_result.data['items'].first

      unless file.nil?
        download_url = file['exportLinks']['text/plain'] # docs do not have 'downloadUrl' 
        link = file['alternateLink']
        
        if download_url
          result = GoogleClient::download_file download_url
          if result.status == 200

            type, message = FileParser::parse result, file.id, file.title, link, session[:user_id]
            flash[type] = message
            redirect_to file_index_path
          
          else
            flash[:error] = "An error occurred: #{result.data['error']['message']}"
            redirect_to new_file_path
          end # end if result.status == 200
        end # end if download_url

      else # unless
        flash[:error] = "Sorry, EZ Online cannot find a Google Doc with that title."
        redirect_to new_file_path
      end # end unless 

    else
      flash[:error] = "An error occured."
      redirect_to new_file_path   
    end # end outermost if

  end

  def show
  	snippets = Snippet.order(:id)
    docs = Doc.all
    @files = Hash.new

    docs.each do |doc|
      id = doc.read_attribute('doc_id')
      files[doc] = Snippet.where(doc_id: id)
    end
  end

  def history
    @commits = Commit.where(snippet_id: params[:id]).order(id: :desc )
    @snippet = Snippet.find(params[:id])
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

    begin
  	  commit.save!
      flash[:success] = "Update saved."
      redirect_to history_file_path(params[:snippet_id])

    rescue ActiveRecord::ActiveRecordError
      flash.now[:error] = "Failed to save commit."
      render :edit
    end

  end

  def compile
    doc_id = params[:id]

    doc = Doc.find_by doc_id: doc_id
    snippets = Snippet.where(doc_id: doc_id)

    result = Hash.new
    snippets.each do |s|
      result[s.title] = Commit.where(snippet_id: s.id)
                              .order(created_at: :desc)
                              .first
                              .commit_text
    end

    tmp = Tempfile.new(doc.docname, Rails.root.join('tmp'))
    begin
      result.each do |title, text|
        tmp.write(title.upcase)
        tmp.write("\n")
        tmp.write(text)
        tmp.write("\n\n")
      end

      result = GoogleClient::upload tmp, doc.docname
      if !result.nil? and result.status == 200
        doc.update_attribute :link, result.data.alternateLink

        flash[:success] = "successfully compiled snippets."
        redirect_to file_index_path
      else
        flash[:error] = "An error occurred: #{result.data['error']['message']}"
        redirect_to file_index_path
      end

    ensure
      tmp.close
      tmp.unlink
    end
  end

  def delete
    Doc.where(doc_id: params[:id]).destroy_all

    flash[:success] = "The file '#{params[:id]}' was successfully removed from the database."

    redirect_to file_index_path
  end

  def fetch_videos #get all videos associated with this file
    doc_id = params[:id]

    doc = Doc.find_by doc_id: doc_id
    snippets = Snippet.where(doc_id: doc_id)

    snippets.each do |s|
      video_id = VimeoModel::find s.title
      flash[:error] = "Failed to retrieve all videos for this file." unless VimeoModel::save doc.docname, video_id
    end

    redirect_to request.referer
  end

  def fetch_video   #get video for this snippet
    video_id = VimeoModel::find params[:id] #search by snippet title

    flash[:error] = "Failed to retrieve video for this snippet." unless VimeoModel::save params[:id], video_id

    redirect_to request.referer
  end

end

#def compile
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
#end