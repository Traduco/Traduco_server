class CreateProjectTypes < ActiveRecord::Migration
    def change
        create_table :project_types do |t|
            t.integer   :key
            t.string    :name

            t.timestamps
        end
    end
end
