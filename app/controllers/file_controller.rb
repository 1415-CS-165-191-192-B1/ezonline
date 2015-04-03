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
    type, message = GoogleClient::add_file(session[:user_id], params[:title][:text])
    flash[type] = message
    redirect_to :back
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
    saved, type, message = Commit.create_new(session[:user_id], params[:snippet_id], params[:text][:commit_text])

    unless saved
      init_vars   # reinitialize variables after failure in edit
      @commit_text = params[:text][:commit_text]
      flash.now[type] = message
      render :edit # renders edit template
    else 
      flash[type] = message
  	  redirect_to history_file_path(params[:snippet_id])
    end
    
  end

  def init_vars #initialize needed variables in edit view
    @commit = Commit.find(params[:id])
    #snippet = Snippet.find(@commit.snippet_id)
    snippet = @commit.snippet
    @title = snippet.title
    @video_id = snippet.video_id

    #user = User.find(@commit.user_id)
    @username = @commit.user.username
  end

  def compile
    type, message = Filer::write params[:id] # creates gdoc with latest commits
    flash[type] = message
    redirect_to file_index_path
  end

  def delete
    docname = Doc.get_name(params[:id])
    Doc.destroy_all(:doc_id => params[:id])
    flash[:success] = "The file '#{docname}' was successfully removed from the database."
    redirect_to file_index_path
  end

  def fetch_videos # get all videos associated with this file
    doc_id = params[:id]

    doc = Doc.find_by doc_id: doc_id
    snippets = Snippet.where(doc_id: doc_id)

    successes = 0

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
    type, message = Video.create_new(params[:id])
    flash[type] = message
    redirect_to request.referer
  end

  def refresh_videos # gets latest videos since login
    VimeoModel::save_latest 
    redirect_to :back
  end

  def assign
    @doc_id = params[:id]
    doc = Doc.find_by(doc_id: @doc_id)
    @docname = doc.read_attribute('docname')

    @users = User.all
    @current_user = session[:user_id]
  end

  def save_task
    type, message = Task.create_new(params[:user_id].to_i, params[:doc_id])
    flash[type] = message
    redirect_to file_index_path  
  end


end
