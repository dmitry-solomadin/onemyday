class HomeController < ApplicationController

  def index
    @top_stories = Story.top 3
    @recent_stories = Story.recent
  end

end
