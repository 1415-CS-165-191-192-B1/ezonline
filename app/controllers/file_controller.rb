require 'google_client'
require 'vimeo_client'
require 'filer'
require 'tempfile'

class FileController < ApplicationController
  before_action :check_login_state
  before_action :authenticate_admin, :except => [:history, :edit, :update]
  before_action :check_vlogin_state, :only => [:fetch_video, :fetch_videos]
  before_action :save_vlogin_state, :only => [:new]

  def new
  end

  def voptions
  end
  
  def fetch   # called by new to get gdoc from form
    begin
      refreshed ||= false

      #squish: remove whitespaces from both ends, compress multiple to one, blank: check if nil or whitespaces
      search_result = GoogleClient::fetch_file params[:title][:text].squish unless params[:title][:text].blank?
      if search_result.nil?
        flash[:notice] = "Please enter a title."
        redirect_to :back
      elsif search_result.status == 200
        file = search_result.data['items'].first

        unless file.nil?
          download_url = file['exportLinks']['text/plain'] # docs do not have 'downloadUrl' 
          link = file['alternateLink']
          
          if download_url
            result = GoogleClient::download_file download_url
            if result.status == 200

              type, message = Filer::parse result.body, file.id, file.title, link, session[:user_id]
              #type, message = FilerParse.perform_async result.body, file.id, file.title, link, session[:user_id]
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

      elsif search_result.status == 401 # The access token is either expired or invalid.
        GoogleClient::refresh_token
        update_session GoogleClient::get_auth
        raise

      else
        print "**********RESULT STATUS*********** " + search_result.status
        flash[:error] = "An error occured. Please try again later."
        redirect_to new_file_path   
      end # end outermost if

    rescue Exception => ex
      unless refreshed # there was already an attempt to refresh google access token
        refreshed = true
        retry
      end
        print "************ERROR*************" + ex.message
        flash[:error] = "An error occured. Please try again later."
        redirect_to new_file_path   
    end
  end

  def show  # organizes the docs and their corresponding snippets to hash of arrays
  	snippets = Snippet.order(:id)
    docs = Doc.all

    @files = Hash.new
    @workers = Hash.new

    docs.each do |doc|
      id = doc.read_attribute('doc_id')
      @files[doc] = Snippet.where(doc_id: id)

      task = Task.find_by doc_id: id
      user = User.find_by user_id: task.user_id unless task.nil?
      @workers[id] = user.username unless user.nil?
    end
  end

  def history
    @commits = Commit.where(snippet_id: params[:id])
    @snippet = Snippet.find(params[:id])
  end

  def edit
    init_vars
  end

  def update
  	commit = Commit.new
  	commit.user_id = session[:user_id]
  	commit.snippet_id = params[:snippet_id]
  	commit.commit_text = params[:text][:commit_text]

    if commit.valid?
  	  commit.save
      flash[:success] = "Update saved."
      redirect_to history_file_path(params[:snippet_id])
    else
      flash.now[:notice] = "Your commit was empty/too short."
      @commit_text = commit.commit_text
      init_vars   # reinitialize variables after failure in edit
      render :edit # renders edit template
    end
  end

  def init_vars #initialize needed variables in edit view
    @commit_id = params[:id]
    @commit = Commit.find(@commit_id)
    snippet = Snippet.find(@commit.snippet_id)
    @title = snippet.title
    @video_id = snippet.video_id
    user = User.find(@commit.user_id)
    @username = user.username
  end

  def compile
    type, message = Filer::write params[:id] # creates gdoc with latest commits
    flash[type] = message
    redirect_to file_index_path
  end

  def delete
    doc_id = params[:id]

    doc = Doc.find_by doc_id: doc_id
    docname = doc.read_attribute('docname')

    Doc.destroy_all(:doc_id => doc_id)

    flash[:success] = "The file '#{docname}' was successfully removed from the database."

    redirect_to file_index_path
  end

  def fetch_videos # get all videos associated with this file
    doc_id = params[:id]

    doc = Doc.find_by doc_id: doc_id
    snippets = Snippet.where(doc_id: doc_id)

    successes = 0
    failures = 0

    snippets.each do |s|
      video_id = VimeoModel::find s.title # returns nil if none
      successes += 1 if VimeoModel::save s.title, video_id # returns true if snippet was updated with video_id
    end

    case successes
    when snippets.size
      flash[:success] = "Successfully added all videos for this file."
    when 0
      flash[:error] = "Failed to add any video for this file."
    when 1..snippets.size
      flash[:notice] = "Some videos were not found for this file."
    end
    redirect_to request.referer
  end

  def fetch_video   # get video for this snippet
    video_id = VimeoModel::find params[:id] # search by snippet title

    if VimeoModel::save params[:id], video_id
      flash[:success] = "Successfully added video for this snippet."
    else
      flash[:error] = "Failed to retrieve video for this snippet." 
    end

    redirect_to request.referer
  end

  def refresh_videos # gets latest videos since login
    VimeoModel::save_latest 
    redirect_to :back
  end

  def assign
    @doc_id = params[:id]
    doc = Doc.find_by doc_id: @doc_id
    @docname = doc.read_attribute('docname')

    @users = User.all
    @current_user = session[:user_id]
  end

  def save_task
    doc_id = params[:doc_id]
    user_id = params[:user_id].to_i

    old_task = Task.find_by doc_id: doc_id  # doc can only be assigned to one user

    p old_task
    
    if user_id == 0
      old_task.delete if old_task
      flash[:success] = "Successfully unassigned file."  
      redirect_to file_index_path
      return

    else
      user = User.find(user_id)

      if old_task # doc was previously assigned

        if old_task.user_id == user.user_id
          flash[:notice] = "File was already assigned to " + user.username
          redirect_to file_index_path
          return
        else
          old_task.delete
        end # end if old_task user id is selected user_id

      end # end if old_task is not nil

      # create new task
      task = Task.new
      task.admin_id = session[:user_id]
      task.user_id = user_id
      task.doc_id = doc_id
      task.save

      flash[:success] = "Successfully assigned file to " + user.username
      redirect_to file_index_path
      return

    end # end if user_id is 0
     
  end # end method save_task




end
