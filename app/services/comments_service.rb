class CommentsService

  def self.create(params, creator)
    story = Story.find(params[:story_id])
    comment = story.comments.build(params[:comment])
    comment.user = creator

    # todo might be a good idea to refactor this into story model
    discussion_members = []
    story.comments.each { |c| discussion_members<<c.user }
    discussion_members.uniq_by{|member| member.id}.each do |member|
      next if member.id == story.user.id || member.id == comment.user.id
      ActivityTracking.track comment, member, "discussion_member"
    end

    comment.save!
    ActivityTracking.track comment, story.user unless story.user.id == comment.user.id
    comment
  end

end
