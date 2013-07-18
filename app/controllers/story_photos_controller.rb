class StoryPhotosController < ApplicationController

  before_filter :load_story_photo

  def destroy
    @story_photo.story_element.destroy

    respond_to do |format|
      format.js
      format.html { redirect_to story_path(@story_photo.story.id) }
    end
  end

  def update
    @story_photo.update_attributes(params[:story_photo])

    render nothing: true
  end

  private

  def load_story_photo
    @story_photo = StoryPhoto.find(params[:id])

    Story.unscoped do
      raise Onemyday::AccessDenied unless current_user? @story_photo.story.user
    end
  end

end
