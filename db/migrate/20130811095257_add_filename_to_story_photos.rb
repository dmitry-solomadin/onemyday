class AddFilenameToStoryPhotos < ActiveRecord::Migration
  def change
    add_column :story_photos, :filename, :string
  end
end
