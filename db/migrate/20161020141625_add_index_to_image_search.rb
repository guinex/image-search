class AddIndexToImageSearch < ActiveRecord::Migration[5.0]
  def change
    add_index :image_searches, :fingerprint
  end
end
