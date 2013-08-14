class AddReportedForToStories < ActiveRecord::Migration
  def change
    add_column :stories, :reported_for, :string
  end
end
