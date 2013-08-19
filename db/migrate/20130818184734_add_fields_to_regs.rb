class AddFieldsToRegs < ActiveRecord::Migration
  def change
    add_column :regs, :nickname, :string
    add_column :regs, :admin, :boolean
    add_column :regs, :email, :string
  end
end
