class AddLikesAndViewsCountToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :likes_count, :integer, default: 0
    add_column :stories, :views_count, :integer, default: 0

    Story.reset_column_information
    Story.select(:id).find_each do |p|
      Story.reset_counters p.id, :likes
      Story.reset_counters p.id, :views
    end
  end

  def self.down
    remove_column :stories, :likes_count
    remove_column :stories, :views_count
  end
end
