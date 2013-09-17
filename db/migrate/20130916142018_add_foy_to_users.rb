class AddFoyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :foy, :boolean
  end
end
