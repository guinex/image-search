class CreateFailedImages < ActiveRecord::Migration[5.0]
  def change
    create_table :failed_images do |t|
      t.string :image_id
      t.integer :failed_count, default: 1
      t.string :state, default: 'waiting'
      t.timestamps
    end
  end
end
