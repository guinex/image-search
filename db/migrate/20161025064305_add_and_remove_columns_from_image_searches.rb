class AddAndRemoveColumnsFromImageSearches < ActiveRecord::Migration[5.0]
  def change
    remove_column :image_searches, :design_ids
    add_column :image_searches, :color_histogram, :text
  end
end
