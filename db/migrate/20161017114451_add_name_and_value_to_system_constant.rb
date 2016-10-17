class AddNameAndValueToSystemConstant < ActiveRecord::Migration[5.0]
  def change
    add_column :system_constants, :name, :text
    add_column :system_constants, :value, :text
  end
end
