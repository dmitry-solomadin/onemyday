class AddAttachmentPhotoToStoryPhotos < ActiveRecord::Migration
  def self.up
    change_table :story_photos do |t|
      t.has_attached_file :photo
    end
  end

  def self.down
    drop_attached_file :story_photos, :photo
  end
end
