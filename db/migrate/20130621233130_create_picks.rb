class CreatePicks < ActiveRecord::Migration
  def change
    create_table :picks do |t|
      t.integer :entry_id
      t.string :pick
      t.integer :points

      t.timestamps
    end
  end
end
