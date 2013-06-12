class Api::CommentsController < Api::ApiController

  def create
    begin
      creator = User.find(params[:creator_id])
      comment = CommentsService.create(params, creator)
      render json: comment
    rescue => e
      render json: {message: e.message, backtrace: e.backtrace}
    end
  end

  def destroy
    begin
      comment = Comment.find(params[:id])
      comment.destroy
      render json: {success: true}
    rescue => e
      render json: {message: e.message, backtrace: e.backtrace}
    end
  end

end