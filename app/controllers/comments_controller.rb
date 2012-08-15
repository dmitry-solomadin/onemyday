class CommentsController < ApplicationController

  before_filter :signed_in_user_filter, only: [:create]

  layout false, only: :create

  def create
    story = Story.find(params[:story_id])
    @comment = story.comments.build(params[:comment])
    @comment.user = current_user

    @comment.save!

    respond_to { |t| t.js }
  end

end
