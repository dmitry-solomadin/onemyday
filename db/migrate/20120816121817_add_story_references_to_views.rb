class AddStoryReferencesToViews < ActiveRecord::Migration
  def change
    change_table(:views) do |t|
      t.references :story
    end

    add_index :views, :story_id
  end
end
