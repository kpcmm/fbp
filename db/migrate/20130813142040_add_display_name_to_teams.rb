class AddDisplayNameToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :display_name, :string
  end
end
