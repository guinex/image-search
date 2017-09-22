class RenameColumns < ActiveRecord::Migration[5.0]
  def up
    rename_column :cluster_relations, :parent_id, :related_id
    remove_column :color_clusters, :average
    remove_column :color_clusters, :average_distance
    remove_column :color_clusters, :key_hash
    add_column :color_clusters, :gray_scaled, :text
    add_column :color_clusters, :color_scaled, :text
    add_column :color_clusters, :category_id, :integer
    remove_column :image_searches, :processed_for_equal_at
    remove_column :image_searches, :processed_for_similar_at
    remove_column :image_searches, :similar_designs
  end
  def down
    rename_column :cluster_relations, :related_id, :parent_id
    add_column :color_clusters, :average, :float
    add_column :color_clusters, :average_distance, :float
    add_column :color_clusters, :key_hash, :text
    remove_column :color_clusters, :gray_scaled
    remove_column :color_clusters, :color_scaled
    remove_column :color_clusters, :category_id
    add_column :image_searches, :processed_for_equal_at, :datetime
    add_column :image_searches, :processed_for_similar_at, :datetime
    add_column :image_searches, :similar_designs, :text
  end

end
