class Api::StoriesController < Api::ApiController
  def like
    begin
      story = Story.find(params[:id])
      like = story.likes.build(user_id: params[:user_id])
      like.save!
      ActivityTracking.track like, story.user
      render json: {success: true}
    rescue => e
      render json: {message: e.message, backtrace: e.backtrace}
    end
  end

  def unlike
    begin
      Story.find(params[:id]).likes.find_by_user_id(params[:user_id]).destroy
      render json: {success: true}
    rescue => e
      render json: {message: e.message, backtrace: e.backtrace}
    end
  end

  def update
    begin
      Story.find(params[:id]).update_attributes(params[:story])
      render json: {success: true}
    rescue => e
      render json: {message: e.message, backtrace: e.backtrace}
    end
  end

  def create_and_publish
    begin
      user = User.find(params[:author_id])
      story = user.stories.build(params[:story])
      story.published = true
      params[:story_photos].each do |story_photo|
        story_photo[:orientation] = 1 unless story_photo[:orientation]
        story.story_photos.build story_photo
      end
      params[:story_texts] && params[:story_texts].each do |story_text|
          story.story_texts.build story_text
      end
      story.save

      if story.valid?
        render json: {story_id: story.id, status: "success"}
      else
        render json: {errors: story.errors, status: "bad_request"}
      end
    rescue => e
      render json: {message: e.message, backtrace: e.backtrace}
    end
  end

end