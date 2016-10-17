class ChangeColumnDesignIdsImageSearch < ActiveRecord::Migration[5.0]
  def change
    add_column :image_searches, :design_id, :string
    add_column :image_searches, :image_id, :string
  end
end
