class RenameColumns < ActiveRecord::Migration[5.0]
  def change
    rename_column :cluster_relations, :parent_id, :related_id
    remove_column :color_clusters, :average
    remove_column :color_clusters, :average_distance
    remove_column :color_clusters, :key_hash
    remove_column :image_searches, :category_id
    add_cloumn :color_clusters, :gray_scaled, :text
    add_cloumn :color_clusters, :color_scaled, :text
    add_cloumn :color_clusters, :category_id, :integer
    remove_column :image_searches, :processed_for_equal_at
    remove_column :image_searches, :processed_for_similar_at
    remove_column :image_searches, :similar_designs
  end
end
