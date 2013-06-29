class ActivitiesController < ApplicationController

  def index
    @activities = User.find(params[:id]).activities.order("created_at DESC")
    @activities = @activities.where("id > #{params[:higher_than_id]}") if params[:higher_than_id]
    @activities = @activities.where("id < #{params[:lower_than_id]}") if params[:lower_than_id]
    @activities = @activities.limit(params[:limit]) if params[:limit]
    @activities.unseen.each do |activity|
      activity.update_attribute(:viewed, true)
    end
    respond_to do |f|
      f.js
      f.json { render :json => ActivityFormat.get_hash_for_multiple(@activities) }
    end
  end

end
