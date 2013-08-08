class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.string :nickname
      t.string :code
      t.string :city
      t.string :image_file_name

      t.timestamps
    end
    add_index :teams, :name, unique: true
    add_index :teams, :nickname, unique: true
    add_index :teams, :code, unique: true
  end
end
