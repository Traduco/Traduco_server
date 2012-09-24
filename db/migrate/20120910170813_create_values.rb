class CreateValues < ActiveRecord::Migration
  def change
    create_table :values do |t|
      t.text :value
      t.text :comment

      t.boolean :is_translated
      t.boolean :is_stared

      t.integer :key_id
      t.integer :translation_id

      t.timestamps
    end
  end
end
