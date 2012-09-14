class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.boolean :cloned		
      
      t.integer :project_type_id
      t.integer :default_language_id

      t.integer :repository_type_id
      t.string :repository_address
      t.text :repository_ssh_key

      t.timestamps
    end
  end
end
