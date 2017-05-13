class AddClusterIdToImageSearch < ActiveRecord::Migration[5.0]
  def change
   add_column :image_searches, :cluster_id, :string
  end
end
