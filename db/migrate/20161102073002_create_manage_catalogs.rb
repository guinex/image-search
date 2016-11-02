class CreateManageCatalogs < ActiveRecord::Migration[5.0]
  def change
    create_table :manage_catalogs do |t|

      t.timestamps
    end
  end
end
