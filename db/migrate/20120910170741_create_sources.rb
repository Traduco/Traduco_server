class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.string :file_path
      t.integer :project_id
      t.integer :source_type_id

      t.timestamps
    end
  end
end
