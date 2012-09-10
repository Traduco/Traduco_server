class CreateValues < ActiveRecord::Migration
  def change
    create_table :values do |t|
      t.string :value
      t.boolean :isTranslated
      t.boolean :isStared
      t.integer :key_id

      t.timestamps
    end
  end
end
