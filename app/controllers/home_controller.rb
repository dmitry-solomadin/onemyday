class HomeController < ApplicationController

  def index
    @stories = Story.find_all_by_published(true)
  end

end
