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
end