class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.integer :tiebreak
      t.string :status
      t.integer :user_id
      t.integer :week_id

      t.timestamps
    end
    add_index :entries, [:week_id, :user_id], unique: true
    add_index :entries, :user_id
  end
end
