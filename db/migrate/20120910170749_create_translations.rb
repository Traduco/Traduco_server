class CreateTranslations < ActiveRecord::Migration
  def change
    create_table :translations do |t|
    	t.integer :project_id
    	t.integer :language_id
    	t.integer :value_id
    	t.boolean :lock
    	t.datetime :lockDate

      t.timestamps
    end
  end
end
