class AddDesignsIdsFingerprintToImages < ActiveRecord::Migration[5.0]
  def change
    add_column :images, :fingerprint, :string
    add_column :images, :design_ids, :text
  end
end
