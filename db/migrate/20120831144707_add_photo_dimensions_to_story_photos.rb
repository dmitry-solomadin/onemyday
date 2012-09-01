class AddPhotoDimensionsToStoryPhotos < ActiveRecord::Migration
  def change
    add_column :story_photos, :photo_dimensions, :string
  end
end