class ChangeStoryPhotoDimensions < ActiveRecord::Migration
  def change
    change_column :story_photos, :photo_dimensions, :text
  end
end
