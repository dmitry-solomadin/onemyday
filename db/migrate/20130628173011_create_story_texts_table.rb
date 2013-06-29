class CreateStoryTextsTable < ActiveRecord::Migration
  def change
    create_table :story_texts do |t|
      t.text :text
      t.timestamps
    end
  end
end
