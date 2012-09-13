class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.integer :language_id
      t.integer :repository_type_id

      t.timestamps
    end
  end
end
