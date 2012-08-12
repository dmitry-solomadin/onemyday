class AddOrientationToStoryPhotos < ActiveRecord::Migration
  def change
    add_column :story_photos, :orientation_cd, :integer
  end
end
