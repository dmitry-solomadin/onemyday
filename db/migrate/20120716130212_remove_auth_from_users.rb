class RemoveAuthFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :uid
    remove_column :users, :provider
  end
end
