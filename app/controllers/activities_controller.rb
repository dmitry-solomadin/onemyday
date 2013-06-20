class ActivitiesController < ApplicationController

  def index
    @activities = User.find(params[:id]).activities.order("created_at DESC")
    @activities.unseen.each do |activity|
      activity.update_attribute(:viewed, true)
    end
    respond_to do |f|
      f.js
      f.json { render :json => ActivityFormat.get_hash_for_multiple(@activities) }
    end
  end

end
