class UserStoriesController < ApplicationController

  layout false

  def own
    @user = User.find(params[:user_id])
    @stories = @user.stories

    respond_to { |t| t.js }
  end

  def liked
    @stories = User.find(params[:user_id]).liked_stories

    respond_to { |t| t.js }
  end

  def unfinished
    @stories = User.find(params[:user_id]).stories.unpublished

    respond_to { |t| t.js }
  end

end
