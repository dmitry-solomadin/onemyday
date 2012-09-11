class StoryPhotosController < ApplicationController

  layout false, only: [:destroy]

  def destroy
    @story_photo = StoryPhoto.find(params[:id])

    raise AccessDenied unless is_current_user @story_photo.story.user

    @story_photo.destroy

    respond_to do |format|
      format.js
      format.html { redirect_to story_path(@story_photo.story.id) }
    end
  end

end
