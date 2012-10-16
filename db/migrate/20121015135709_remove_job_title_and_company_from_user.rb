class RemoveJobTitleAndCompanyFromUser < ActiveRecord::Migration
  def up
    remove_column :users, :job_title
    remove_column :users, :company
  end

  def down
    add_column :users, :company, :string
    add_column :users, :job_title, :string
  end
end
