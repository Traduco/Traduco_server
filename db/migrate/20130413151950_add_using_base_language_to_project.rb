class AddUsingBaseLanguageToProject < ActiveRecord::Migration
  def change
    add_column :projects, :using_base_language, :boolean, :default => false
  end
end
