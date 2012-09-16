class CreateKeys < ActiveRecord::Migration
  def change
    create_table :keys do |t|
      t.string 	:key

      t.integer	:source_id
      t.integer :default_value_id

      t.timestamps
    end
  end
end
