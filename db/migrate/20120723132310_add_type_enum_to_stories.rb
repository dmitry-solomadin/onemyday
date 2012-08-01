class AddTypeEnumToStories < ActiveRecord::Migration
  def change
    add_column :stories, :type_cd, :integer
  end
end
