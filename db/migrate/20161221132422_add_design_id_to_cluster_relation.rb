class AddDesignIdToClusterRelation < ActiveRecord::Migration[5.0]
  def change
   add_column :cluster_relations, :design_id, :string
  end
end
