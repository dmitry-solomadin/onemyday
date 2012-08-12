class StoriesController < ApplicationController

  before_filter :signed_in_user_filter, except: :show

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
    @story = Story.find(params[:id])
  end

  layout false, only: :create

  def create
    @story = @current_user.stories.build(params[:story])
    @story.save

    respond_to do |t|
      t.js
    end
  end

  def upload_photo
    # On this step we should already have created story, so here
    # we would just add StoryImage(-s) to this story and display it(them)
    # on the view.
    @story = @current_user.stories.find(params[:story_id])
    params[:file_bean].each do |file_bean|
      @story.story_photos.build photo: file_bean
    end
    @story.save

    render 'uploaded_photos', layout: nil
  end

  def publish
    @story = @current_user.stories.find(params[:story][:id])

    if @story.update_attributes(params[:story])
      redirect_to @story, action: "new"
    else
      render "new"
    end
  end

end
