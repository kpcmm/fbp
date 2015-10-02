class AddPointsToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :points, :integer
  end
end
