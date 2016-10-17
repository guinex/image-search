class AddSimilarDesignsToImage < ActiveRecord::Migration[5.0]
  def change
   add_column :image_searches, :similar_designs, :text
  end
end
