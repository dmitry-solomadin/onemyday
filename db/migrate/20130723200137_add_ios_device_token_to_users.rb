class AddIosDeviceTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :ios_device_token, :string
  end
end
