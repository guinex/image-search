class RenameTypeToRelationType < ActiveRecord::Migration[5.0]
  def change
   rename_column :cluster_relations, :type, :relation_type
  end
end
