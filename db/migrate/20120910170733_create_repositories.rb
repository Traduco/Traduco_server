class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.string :sshKey
      t.string :name
      t.string :address
      t.integer :repositoryType_id # foreign key
      t.integer :project_id

      t.timestamps
    end
  end
end
