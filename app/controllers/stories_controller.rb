class StoriesController < ApplicationController

  before_filter :signed_in_user_filter, except: :show
  layout false, only: [:create, :destroy]

  def index
    @stories = Story.all

    render "_list_stories"
  end

  def search
    @query = params[:q]
    @stories = Story.where("title like '%#@query%'")
  end

  def new
    return redirect_to moreinfo_url if current_user.job_title.blank? || current_user.company.blank?

    render "new"
  end

  def show
    @story = Story.unscoped.find(params[:id])

    @story.views.build(date: DateTime.now).save!
  end

  def create
    @story = @current_user.stories.build(params[:story])
    @story.save

    respond_to { |t| t.js }
  end

  def upload_photo
    # On this step we should already have created story, so here
    # we would just add StoryImage(-s) to this story and display it(them)
    # on the view.
    @story = @current_user.stories.unscoped.find(params[:story_id])
    params[:file_bean].each do |file_bean|
      @story.story_photos.build photo: file_bean
    end
    @story.save

    @story_photos = @story.story_photos

    render 'uploaded_photos', layout: nil
  end

  def publish
    @story = @current_user.stories.unscoped.find(params[:story][:id])

    if @story.has_photos && @story.update_attributes(params[:story])
      redirect_to @story
    else
      render "new"
    end
  end

  def like
    Story.find(params[:story_id]).likes.build(user_id: current_user.id).save!
    render nothing: true
  end

  def unlike
    Story.find(params[:story_id]).likes.find_by_user_id(current_user.id).destroy
    render nothing: true
  end

  def destroy
    @story_id = params[:id]
    Story.unscoped.find(@story_id).destroy

    respond_to do |format|
      format.js
      format.html { redirect_to current_user }
    end
  end

  def edit
    @story = Story.unscoped.find(params[:id])
  end

end
