class StoryFormat

  def self.to_json(story, params)
    include = []
    include<<:comments if params[:c]
    include<<{:user => {:methods => :avatar_urls}} if params[:u]
    include<<{:story_photos => {:methods => :photo_urls}} if params[:p]
    story.current_user = User.find(params[:requesting_user_id]) if params[:requesting_user_id]
    story.to_json(:include => include, :methods => :is_liked_by_user)
  end

end