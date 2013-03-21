class ActivitiesController < ApplicationController

  def index
    @activities = current_user.activities
    @activities.unseen.each do |activity|
      activity.update_attribute(:viewed, true)
    end
    respond_to do |f|
      f.js
    end
  end

end
