class AddTimeTakenToStoryPhotos < ActiveRecord::Migration
  def change
    add_column :story_photos, :time_taken, :string
  end
end
