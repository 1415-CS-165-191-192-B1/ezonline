require 'google_client'
require 'vimeo_client'
require 'filer'
require 'tempfile'

class FileController < ApplicationController
  before_action :check_login_state
  before_action :check_vlogin_state, :only => [:fetch_video, :fetch_videos]
  before_action :set_access_from_session, :only => [:fetch, :compile]

  #
  #
  def new
  end

  # Fetches the GDoc
  #
  # @return [void]
  # @note Called by new to get gdoc from form
  def fetch
    type, message = GoogleClient::add_file(session[:user_id], params[:title][:text])
    flash[type] = message
    redirect_to :back
  end

  # Organizes the docs and their corresponding snippets to hash of arrays
  #
  # @return [void]
  def show
    @files, @workers = Doc.get_all
  end

  # Contains the commit history of this snippet
  #
  # @return [void]
  def history
    @commits = Commit.where(snippet_id: params[:id])
    @snippet = Snippet.find(params[:id])
  end

  # Edits this snippet
  #
  # @return [void]
  def edit
    init_vars
  end

  # Updates this snippet
  #
  # @return [void]
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

  # Initializes needed variables in edit view
  #
  # @return [void]
  def init_vars
    @commit = Commit.find(params[:id])
    snippet = @commit.snippet
    @title = snippet.title
    @video_id = snippet.video_id
    @username = @commit.user.username
  end

  # Creates gdoc with latest commits
  #
  # @return [void]
  def compile
    type, message = Filer::write params[:id]
    flash[type] = message
    redirect_to file_index_path
  end

  # Deletes this snippet
  #
  # @return [void]
  def delete
    type, message = Doc.delete_and_respond(params[:id])
    redirect_to file_index_path
  end

  # Gets all videos associated with this file
  #
  # @return [void]
  def fetch_videos
    type, message = Snippet.update_video_ids(params[:id]) # pass doc_id
    flash[type] = message
    redirect_to request.referer
  end

  # Gets video for this snippet
  #
  # @return [void]
  def fetch_video
    type, message = Snippet.update_video_id(params[:id])
    flash[type] = message
    redirect_to request.referer
  end

  # Gets latest videos since login
  #
  # @return [void]
  def refresh_videos
    VimeoClient::save_latest
    redirect_to :back
  end

  # Assigns this snippet
  #
  # @return [void]
  def assign
    @doc_id = params[:id]
    @docname = Doc.get_name(@doc_id)
    @users = User.where.not(admin: true)
    @current_user = session[:user_id]
  end

  # Saves the tasks for this snippet
  #
  # @return [void]
  def save_task
    type, message = Task.create_new(session[:user_id], params[:user_id].to_i, params[:doc_id])
    flash[type] = message
    redirect_to file_index_path
  end


end
