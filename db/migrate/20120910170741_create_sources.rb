class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.string :filePath
      t.integer :project_id
      t.integer :sourceType_id

      t.timestamps
    end
  end
end
