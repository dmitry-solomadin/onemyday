class RemoveTypeEnumFromStories < ActiveRecord::Migration
  def change
    remove_column :stories, :type_cd
  end
end
