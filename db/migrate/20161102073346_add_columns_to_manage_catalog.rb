class AddColumnsToManageCatalog < ActiveRecord::Migration[5.0]
  def change
   add_column :manage_catalogs, :design_id, :string
   add_column :manage_catalogs, :geo, :string
   add_column :manage_catalogs, :processing_state, :string, default: 'waiting'
  end
end
