class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.belongs_to :user
      t.string :reason
      t.belongs_to :trackable
      t.string :trackable_type
      t.boolean :viewed, default: false

      t.timestamps
    end
    add_index :activities, :user_id
    add_index :activities, :trackable_id
  end
end
