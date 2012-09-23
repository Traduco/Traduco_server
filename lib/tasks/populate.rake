require "bcrypt"

namespace :db do
    desc "Populate all languages and repository type"
    task :populate => :environment do
    
    [Language, RepositoryType, ProjectType, User].each(&:delete_all)
    
    File.open('lib/tasks/languages.txt', 'r').each_line do |line|
        name, format = line.split ':', 2
        language = Language.new({
            :format => format.delete("\n"), 
            :name => name
        })
        language.save
    end
    
    File.open('lib/tasks/repoType.txt', 'r').each_line do |line|
        name, key = line.split ':', 2
        repository_type = RepositoryType.new({
            :key => key.delete("\n"), 
            :name => name
        })
        repository_type.save
    end   

    File.open('lib/tasks/projectType.txt', 'r').each_line do |line|
        name, key = line.split ':', 2
        project_type = ProjectType.new({
            :key => key.delete("\n"), 
            :name => name
        })
        project_type.save
    end   

    admin = User.new({
        :first_name => "Main",
        :last_name => "Admin",
        :new_password => "admin_password",
        :new_password_confirmation => "admin_password",
        :email => "admin@traduco.com",
        :is_site_admin => true
    })
    admin.save
 
  end
end