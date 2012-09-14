class AddLikesAndViewsCountToStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :likes_count, :integer, default: 0
    add_column :stories, :views_count, :integer, default: 0

    Story.reset_column_information
    Story.all.each do |story|
      Story.update_counters story.id, likes_count: story.likes.length
      Story.update_counters story.id, views_count: story.views.length
    end
  end

  def self.down
    remove_column :stories, :likes_count
    remove_column :stories, :views_count
  end
end
