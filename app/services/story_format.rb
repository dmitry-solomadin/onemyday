class StoryFormat

  def self.to_json(story, params)
    include = []
    include<<:comments if params[:c]
    include<<{:user => {:methods => :avatar_urls}} if params[:u]
    include<<{:story_photos => {:methods => :photo_urls}} if params[:p]

    # add requesting user to each story model so it can say whether it was liked by him.
    if params[:requesting_user_id]
      u = User.find(params[:requesting_user_id])
      if story.kind_of?(Array)
        story.each { |s| s.current_user = u }
      else
        story.current_user = u
      end
    end

    story.to_json(:include => include, :methods => :is_liked_by_user)
  end

end