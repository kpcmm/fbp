class CreateAgreements < ActiveRecord::Migration
  def change
    create_table :agreements do |t|
      t.integer :user_id
      t.integer :season_id

      t.boolean :foy
      t.boolean :paid

      t.timestamps
    end
    
    add_index :agreements, :user_id
    add_index :agreements, :season_id
    add_index :agreements, [:user_id, :season_id], unique: true
  end
end
