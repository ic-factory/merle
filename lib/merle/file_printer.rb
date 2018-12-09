
module Merle

  class FilePrinter < Printer

    def initialize (filename)
      @filename = File.expand_path(filename)
      #Truncate the file (or create it if non existing:)
      begin
        FileUtils.mkdir_p File.dirname(@filename)       
        File.open(@filename, 'w') { |f| }
      rescue Errno::ENOENT, Errno::EACCES => e
        raise IOError, "#{@filename} file could not be created."
      end
    end

    def output(str)
      #Open for append, write and and close it:
      begin
        File.open(@filename, 'a') { |file| file.write("#{str}\n") }
      rescue Errno::ENOENT => e
        raise IOError, "#{@filename} file could not be written."
      end
    end
  end
end
