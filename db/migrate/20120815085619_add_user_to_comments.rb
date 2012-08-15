class AddUserToComments < ActiveRecord::Migration
  def change
    change_table(:comments) do |t|
      t.references :user
    end

    add_index :comments, :user_id
  end
end
