class AddPashObjToImageSearches < ActiveRecord::Migration[5.0]
  def change
   add_column :image_searches, :phash_obj, :binary, :limit => 5.megabyte
  end
end
