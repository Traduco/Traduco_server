class AddClonedToProject < ActiveRecord::Migration
  def change
    add_column :projects, :cloned, :boolean
  end
end
