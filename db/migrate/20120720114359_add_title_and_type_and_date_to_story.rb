class AddTitleAndTypeAndDateToStory < ActiveRecord::Migration
  def change
    add_column :stories, :title, :string
    add_column :stories, :type, :string
    add_column :stories, :date, :datetime
  end
end
