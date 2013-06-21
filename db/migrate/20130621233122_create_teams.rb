class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.string :nickname
      t.string :code
      t.string :image_file_name

      t.timestamps
    end
  end
end
