class AddCommentsCountToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :comments_count, :integer, default: 0

    Story.reset_column_information
    Story.select(:id).find_each do |p|
      Story.reset_counters p.id, :comments
    end
  end

  def self.down
    remove_column :stories, :comments_count
  end
end
