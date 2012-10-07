module CommentsHelper

  # comments are deletable by owners and by owners of stories on which comment has been posted on.
  def comment_deletable?(comment)
    current_user && (comment_owner?(comment) || story_owner?(comment))
  end

  # comments are editable only by users who owns them
  def comment_editable?(comment)
    current_user && comment_owner?(comment)
  end

  def comment_owner?(comment)
    current_user && comment.user.id == current_user.id
  end

  def story_owner?(comment)
    current_user && comment.story.user.id == current_user.id
  end

end
