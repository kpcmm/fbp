class CreateWeeks < ActiveRecord::Migration
  def change
    create_table :weeks do |t|
      t.integer :week_num
      t.integer :season_id

      t.timestamps
    end
    add_index :weeks, [:season_id, :week_num], unique: true
  end
end
