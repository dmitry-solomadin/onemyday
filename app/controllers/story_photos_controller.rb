class StoryPhotosController < ApplicationController

  def destroy
    @story_photo = StoryPhoto.find(params[:id])

    Story.unscoped do
      raise Onemyday::AccessDenied unless current_user? @story_photo.story.user
    end

    @story_photo.destroy

    respond_to do |format|
      format.js
      format.html { redirect_to story_path(@story_photo.story.id) }
    end
  end

end
