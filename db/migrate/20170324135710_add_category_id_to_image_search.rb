class AddCategoryIdToImageSearch < ActiveRecord::Migration[5.0]
  def change
    add_column :image_searches, :category_id, :integer
  end
end
