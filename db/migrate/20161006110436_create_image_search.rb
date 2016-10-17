class CreateImageSearch < ActiveRecord::Migration[5.0]
  def change
    create_table :image_searches do |t|
      t.timestamps
    end
  end
end
