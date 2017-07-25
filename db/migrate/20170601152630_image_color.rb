class ImageColor < ActiveRecord::Migration[5.0]
  def change
    create_table :image_colors do |t|
     t.string :color_hex, null: false
     t.string :color_name
    end
  end
end
