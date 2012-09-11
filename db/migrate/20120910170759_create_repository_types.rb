class CreateRepositoryTypes < ActiveRecord::Migration
  def change
    create_table :repository_types do |t|
      t.integer :type
      t.string 	:name

      t.timestamps
    end
  end
end
