class AddIndexToDesignId < ActiveRecord::Migration[5.0]
  def change
    add_index :image_searches, :design_id
  end
end
