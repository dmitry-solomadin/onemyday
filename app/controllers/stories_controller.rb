class StoriesController < ApplicationController

  before_filter :signed_in_user_filter, except: [:show, :search, :explore, :index, :comments, :likes]

  def index
    @stories = Story.all

    respond_to do |f|
      f.json { render :json => StoryFormat.to_json(@stories, params) }
    end
  end

  def search
    @query = params[:q]

    filter_type = params[:ft].blank? ? StoriesHelper::EXPLORE_FILTER_RECENT : params[:ft].to_i

    @tag = @query.slice(1, @query.length) if @query && @query.start_with?("#")

    if filter_type == StoriesHelper::EXPLORE_FILTER_POPULAR
      @stories = Story.top(nil, @tag)
    elsif filter_type == StoriesHelper::EXPLORE_FILTER_RECENT
      @stories = Story.recent(@tag)
    end

    @stories = @stories.where("title like '%#@query%'") unless @tag
    unless params[:page] == "all"
      @stories = @stories.paginate(page: params[:page])
    end

    @stories = @stories.where("user_id = #{params[:author_id]}") if params[:author_id]

    @stories = @stories.where("id > #{params[:higher_than_id]}") if params[:higher_than_id]
    @stories = @stories.where("id < #{params[:lower_than_id]}") if params[:lower_than_id]
    @stories = @stories.limit(params[:limit]) if params[:limit]

    respond_to do |f|
      f.js
      f.html
      f.json { render :json => StoryFormat.to_json(@stories, params) }
    end
  end

  def explore
    filter_type = params[:ft].blank? ? StoriesHelper::EXPLORE_FILTER_RECENT : params[:ft].to_i

    if filter_type == StoriesHelper::EXPLORE_FILTER_POPULAR
      @stories = Story.top(nil, params[:t]).paginate(page: params[:page])
    elsif filter_type == StoriesHelper::EXPLORE_FILTER_RECENT
      @stories = Story.recent(params[:t]).paginate(page: params[:page])
    end

    respond_to do |f|
      f.js
      f.html { render file: 'stories/explore' }
      f.json { render :json => StoryFormat.to_json(@stories, params) }
    end
  end

  def new
    render "new"
  end

  def show
    @story = Story.unscoped.find(params[:id])

    unless @story.published
      raise Onemyday::AccessDenied unless current_user? @story.user
    end

    @story.views.build(date: DateTime.now).save!

    respond_to do |f|
      f.html
      f.json {
        render :json => StoryFormat.to_json(@story, params)
      }
    end
  end

  def create
    @story = @current_user.stories.build(params[:story])
    @story.save

    respond_to do |t|
      t.js { render json: @story.id }
    end
  end

  def upload_photo
    @story = @current_user.stories.unscoped.find(params[:story_id])

    story_photo = StoryPhoto.create story_id: @story.id, photo: params[:story_photo][:photo], orientation: :center
    @story.story_elements.build element: story_photo, element_order: params[:element_order]
    @story.save

    @story_photos = @story.story_photos

    render 'uploaded_photos', layout: nil
  end

  def publish
    @story = @current_user.stories.unscoped.find(params[:story][:id])

    # do only when story goes from draft to published state
    unless @story.published
      @story.created_at = DateTime.now
      @current_user.followers.each do |follower|
        ActivityTracking.track @story, follower
      end
    end

    if @story.has_photos && @story.update_attributes(params[:story])
      if params[:crosspost_facebook].present? && params[:crosspost_facebook].to_bool &&
          params[:story][:published].to_bool && @current_user.has_facebook?
        pic = @story.story_photos.first.photo.url(:side) # paperclip with s3 will return full url here.
        @current_user.facebook.put_wall_post(@story.title, {name: "onemyday.co", link: story_url(@story), picture: pic})
      end
      redirect_to @story
    else
      render "new"
    end
  rescue Koala::Facebook::APIError => e
    logger.info e.message
    redirect_to story_url(@story) + "#showFacebookNoRights"
  end

  def like
    story = Story.find(params[:story_id])
    like = story.likes.build(user_id: current_user.id)
    like.save!
    ActivityTracking.track like, story.user
    render nothing: true
  end

  def unlike
    Story.find(params[:story_id]).likes.find_by_user_id(current_user.id).destroy
    render nothing: true
  end

  def destroy
    @story = Story.unscoped.find(params[:id])

    raise Onemyday::AccessDenied unless current_user? @story.user

    @story.destroy

    respond_to do |format|
      format.js
      format.html { redirect_to current_user }
    end
  end

  def edit
    @story = Story.unscoped.find(params[:id])

    raise Onemyday::AccessDenied unless current_user? @story.user
  end

  def comments
    comments = Story.find(params[:id]).comments
    respond_to do |f|
      f.json { render json: comments.to_json }
    end
  end

  def likes
    likes = Story.find(params[:id]).likes
    respond_to do |f|
      f.json { render json: likes.to_json }
    end
  end

end
