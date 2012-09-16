class ChangeCaptionFromStringToText < ActiveRecord::Migration
  def change
    change_column :story_photos, :caption, :text
  end
end
