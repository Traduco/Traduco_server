class CreateRepositoryTypes < ActiveRecord::Migration
  def change
    create_table :repository_types do |t|
      t.integer :key
      t.string 	:name

      t.timestamps
    end
  end
end
