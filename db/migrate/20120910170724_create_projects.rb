class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      
      t.integer :default_language_id

      t.integer :repository_type_id
      t.string :repository_address
      t.string :repository_ssh_key

      t.timestamps
    end
  end
end
