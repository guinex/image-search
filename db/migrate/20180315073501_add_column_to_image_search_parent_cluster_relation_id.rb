class AddColumnToImageSearchParentClusterRelationId < ActiveRecord::Migration[5.0]
  def change
    add_column :image_searches, :parent_relation_id, :string
  end
end
