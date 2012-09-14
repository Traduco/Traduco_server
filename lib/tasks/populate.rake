namespace :db do
  desc "Populate all languages and repository type"
  task :populate => :environment do
    
    [Language, RepositoryType].each(&:delete_all)
    
    File.open('lib/tasks/languages.txt', 'r').each_line do |line|
    	na, fo = line.split ':', 2
    	l = Language.new({:format => fo, :name => na})
    	l.save
    end
    
 	  File.open('lib/tasks/repoType.txt', 'r').each_line do |line|
    	na, ty = line.split ':', 2
    	r = RepositoryType.new({:key => ty, :name => na})
    	r.save
    end   
 
  end
end