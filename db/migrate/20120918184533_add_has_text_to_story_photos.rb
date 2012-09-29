class AddHasTextToStoryPhotos < ActiveRecord::Migration
  def change
    add_column :story_photos, :has_text, :boolean, default: true
  end
end
