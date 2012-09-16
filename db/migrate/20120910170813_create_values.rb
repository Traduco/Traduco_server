class CreateValues < ActiveRecord::Migration
  def change
    create_table :values do |t|
      t.string :value
      t.string :comment

      t.boolean :is_translated
      t.boolean :is_stared

      t.integer :key_id
      t.integer :translation_id

      t.timestamps
    end
  end
end
