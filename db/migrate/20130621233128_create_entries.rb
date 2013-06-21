class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.integer :tiebreak
      t.string :status
      t.integer :user_id

      t.timestamps
    end
  end
end
