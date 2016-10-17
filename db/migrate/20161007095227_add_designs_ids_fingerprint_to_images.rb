class AddDesignsIdsFingerprintToImages < ActiveRecord::Migration[5.0]
  def change
    add_column :image_searches, :fingerprint, :string
    add_column :image_searches, :design_ids, :text
  end
end
