class AddProcessedForDuplicateAtAndAddProcessedForSimilarAtToImages < ActiveRecord::Migration[5.0]
  def change
    add_column :image_searches, :processed_for_equal_at, :timestamp
    add_column :image_searches, :processed_for_similar_at, :timestamp
  end
end
