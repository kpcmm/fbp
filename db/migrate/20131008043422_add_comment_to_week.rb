class AddCommentToWeek < ActiveRecord::Migration
  def change
    add_column :weeks, :comment, :string
  end
end
