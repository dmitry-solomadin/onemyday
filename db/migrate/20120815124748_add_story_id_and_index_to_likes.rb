class AddStoryIdAndIndexToLikes < ActiveRecord::Migration
  def change
    change_table(:likes) do |t|
      t.references :story
    end

    add_index :likes, :story_id
  end
end
