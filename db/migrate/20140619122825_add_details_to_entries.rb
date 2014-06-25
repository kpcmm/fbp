class AddDetailsToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :details, :string
  end
end
