class CreateViews < ActiveRecord::Migration
  def change
    create_table :views do |t|
      t.datetime :date

      t.timestamps
    end
  end
end
