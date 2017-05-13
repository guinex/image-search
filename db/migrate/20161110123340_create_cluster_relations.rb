class CreateClusterRelations < ActiveRecord::Migration[5.0]
  def change
    create_table :cluster_relations do |t|
      t.string :cluster_id
      t.string :related_id
      t.string :type
      t.integer :grade
      t.integer :z_distance
      t.timestamps
    end
  end
end
