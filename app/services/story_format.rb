class StoryFormat

  def self.to_json(story, params)
    include = []
    include<<:comments if params[:c]
    include<<:user if params[:u]
    include<<{:story_photos => {:methods=> :photo_urls}} if params[:p]
    story.to_json(:include => include)
  end

end