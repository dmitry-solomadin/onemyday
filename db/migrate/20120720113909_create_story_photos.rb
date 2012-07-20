class CreateStoryPhotos < ActiveRecord::Migration
  def change
    create_table :story_photos do |t|
      t.integer :order
      t.integer :story_id

      t.timestamps
    end

    add_index :story_photos, :story_id
  end
end
