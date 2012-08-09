class AddCaptionAndDateToStoryPhotos < ActiveRecord::Migration
  def change
    add_column :story_photos, :caption, :string
    add_column :story_photos, :date, :datetime
  end
end
