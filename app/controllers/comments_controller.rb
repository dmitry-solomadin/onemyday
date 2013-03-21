class CommentsController < ApplicationController

  include CommentsHelper

  before_filter :signed_in_user_filter

  def create
    story = Story.find(params[:story_id])
    @comment = story.comments.build(params[:comment])
    @comment.user = current_user

    discussion_members = []
    story.comments.each { |comment| discussion_members<<comment.user }
    discussion_members.uniq_by{|member| member.id}.each do |member|
      next if member.id == story.user.id || member.id == @comment.user.id
      track_activity @comment, member, "discussion_member"
    end

    @comment.save!
    track_activity @comment, story.user unless story.user.id == @comment.user.id

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
