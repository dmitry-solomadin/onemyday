class TagsController < ApplicationController

  def index
    tags = Story.tag_counts_on(:tags).where("name like ?", "%#{params[:q]}%")
    tag_names = tags.collect { |tag| tag.name }
    tag_names<<params[:q] if tag_names.blank?
    respond_to do |f|
      f.json { render json: tag_names }
    end
  end

end
