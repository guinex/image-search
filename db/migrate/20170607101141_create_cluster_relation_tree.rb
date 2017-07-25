class CreateClusterRelationTree < ActiveRecord::Migration[5.0]
  def change
    add_column :cluster_relations, :parent_id, :string
    remove_column :cluster_relations, :design_id,:string
    remove_column :cluster_relations, :related_id,:string
    add_column :color_clusters, :average_distance, :integer
  end
end
