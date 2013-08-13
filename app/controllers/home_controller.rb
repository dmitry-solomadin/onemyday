class HomeController < ApplicationController

  def index
    respond_to do |format|
      @recent_stories = Story.recent.paginate(page: params[:page])
      format.html {
        @top_stories = Story.top_for_home 3
      }
      format.js
    end
  end

end
