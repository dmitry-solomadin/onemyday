class PhotoOrderColumnName < ActiveRecord::Migration
  def up
    rename_column :story_photos, :order, :photo_order
  end

  def down
  end
end
