class CommentsController < CommonCommentsController

  include CommentsHelper

  before_filter :signed_in_user_filter

  def create
    @comment = CommentsService.create(params, current_user)
    respond_to { |t| t.js }
  end

  def update
    @comment = Comment.find(params[:comment][:id])

    if comment_editable? @comment
      @comment.text = params[:comment][:text]
      @comment.save!
      respond_to { |t| t.js }
    end
  end

  def destroy
    @comment = Comment.find(params[:id])

    if comment_deletable? @comment
      @comment.destroy
      respond_to { |t| t.js }
    end
  end

end
