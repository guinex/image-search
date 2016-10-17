class SystemConstant < ActiveRecord::Migration[5.0]
  def change
    create_table :system_constants do |t|
      t.timestamps
    end
  end
end
