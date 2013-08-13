class AddStatusToWeeks < ActiveRecord::Migration
  def change
    add_column :weeks, :status, :string
  end
end
