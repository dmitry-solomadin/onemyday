class AddCommentIdIndexToComments < ActiveRecord::Migration
  def change
    change_table(:comments) do |t|
      t.references :comment
    end

    add_index :comments, :comment_id
  end
end
