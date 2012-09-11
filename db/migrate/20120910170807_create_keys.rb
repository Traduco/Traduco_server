class CreateKeys < ActiveRecord::Migration
  def change
    create_table :keys do |t|
      t.string 	:key
      t.string 	:comment
      t.integer	:value_id

      t.timestamps
    end
  end
end
