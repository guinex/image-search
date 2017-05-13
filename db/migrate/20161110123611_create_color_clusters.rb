class CreateColorClusters < ActiveRecord::Migration[5.0]
  def change
    create_table :color_clusters do |t|
      t.float :average
      t.string :color_hash_percent
      t.string :key_hash
      t.timestamps
    end
  end
end
