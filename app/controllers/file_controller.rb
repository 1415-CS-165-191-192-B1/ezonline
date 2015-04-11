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
  
  def fetch   # called by new to get gdoc from form
    type, message = GoogleClient::add_file(session[:user_id], params[:title][:text])
    flash[type] = message
    redirect_to :back
  end

  def show  # organizes the docs and their corresponding snippets to hash of arrays
    @files, @workers = Doc.get_all
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
    snippet = @commit.snippet
    @title = snippet.title
    @video_id = snippet.video_id
    @username = @commit.user.username
  end

  def compile
    type, message = Filer::write params[:id] # creates gdoc with latest commits
    flash[type] = message
    redirect_to file_index_path
  end

  def delete
    type, message = Doc.delete_and_respond(params[:id])
    redirect_to file_index_path
  end

  def fetch_videos # get all videos associated with this file
    type, message = Snippet.update_video_ids(params[:id]) # pass doc_id
    flash[type] = message
    redirect_to request.referer
  end

  def fetch_video   # get video for this snippet
    type, message = Snippet.update_video_id(params[:id])
    flash[type] = message
    redirect_to request.referer
  end

  def refresh_videos # gets latest videos since login
    VimeoClient::save_latest 
    redirect_to :back
  end

  def assign
    @doc_id = params[:id]
    @docname = Doc.get_name(@doc_id)
    @users = User.where.not(admin: true)
    @current_user = session[:user_id]
  end

  def save_task
    type, message = Task.create_new(session[:user_id], params[:user_id].to_i, params[:doc_id])
    flash[type] = message
    redirect_to file_index_path  
  end


end
