class CreateSubapps < ActiveRecord::Migration[5.0]
  def change
    create_table :subapps do |t|
      t.string :appname, null: false, default: ""
      t.string :description
      t.timestamps
    end
  end
end
