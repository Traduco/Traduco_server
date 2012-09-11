class CreateSourceTypes < ActiveRecord::Migration
  def change
    create_table :source_types do |t|
      t.string :name
      t.integer :type

      t.timestamps
    end
  end
end
