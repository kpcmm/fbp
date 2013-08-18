class CreateRegs < ActiveRecord::Migration
  def change
    create_table :regs do |t|
      t.string :name

      t.timestamps
    end
  end
end
