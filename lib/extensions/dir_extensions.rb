class Dir
    def self.mkpath (path)
        return if File.exists?(path)

        dir, file = File.split path 
        
        Dir.mkpath(dir) if !File.exists?(dir)
        Dir.mkdir path
    end
end