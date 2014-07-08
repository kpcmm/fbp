class DropPicksTable < ActiveRecord::Migration
  def up
    drop_table :picks
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
