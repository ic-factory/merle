module Merle

  class MakefileCreator

    def initialize (root_dir,scope,output_directory)
      #TBA: consider providing the scope to the Project constructor.
      @project = ::Ecic::Project.new(root_dir)
      @scope = scope
      @output_directory = output_directory
    end

    def load_libraries
      #TBA: apply scope
      @project.load_libraries
      self
    end

    def load_all_source_files
      @project.libraries.each do |lib|
        #TBA: apply scope
        lib.load_sources
      end
    end

    #The following command must write the output to the 'output_dir' folder.
    def create_library_list
      printer = @output_directory.nil? ? Printer.new : FilePrinter.new("#{@output_directory}/libraries.make")
      @project.libraries.each do |lib|
        library_sources_file = "$(path_prefix)/#{lib.name}/library_sources.make"
        printer.output <<~HEREDOC
          #{library_sources_file} : $(project_root_dir)/#{lib.path}/sources.rb
          \t@set -euo pipefail; cd $(project_root_dir);\\
          \tmkdir -p $(@D);\\
          \techo \"Generating $@\";\\
          \tmerle library_sources #{lib.name} > $@
          \nlibrary_sources += #{library_sources_file}
          HEREDOC
      end
      printer.output 'all_libraries := ' + @project.libraries.map{ |lib| "$(path_prefix)/#{lib.name}.lib" }.join(" ")
    end

    #lib argument can either be a library name of a library object,
    def create_library_sources(lib)
      library = lib.is_a?(String) ? @project.get_library(lib) : lib
      printer = @output_directory.nil? ? Printer.new : FilePrinter.new("#{@output_directory}/#{library.name}/library_sources.make")
      library.source_files.each do |src_file|
        input_file  = "$(project_root_dir)/#{library.path}/#{src_file}"
        #TBA: Use a shared function to get the path for the expected .d file:
        output_file = "$(path_prefix)/#{library.name}/#{src_file}.d.libraries"
        printer.output <<~HEREDOC
          #{output_file} : #{input_file}
          \t@set -euo pipefail; cd $(project_root_dir);\\
          \tmkdir -p $(@D);\\
          \techo \"Generating $@\";\\
          \tmerle library_dependencies #{library.name} $(project_root_dir) #{library.path}/#{src_file.path} > $@
          \nlibrary_level_dependency_files += #{output_file}
          HEREDOC
        #####################################################################################
        #TBA: Consider placing the following in a separate file, since the content is not
        #needed at libray-level dependencies.
        output_file = "$(path_prefix)/#{library.name}/#{src_file}.d.sublevel"
        printer.output <<~HEREDOC
          #{output_file} : #{input_file}
          \t@set -euo pipefail; cd $(project_root_dir);\\
          \tmkdir -p $(@D);\\
          \techo \"Generating $@\";\\
          \tmerle file_dependencies #{library.name} $(project_root_dir) #{library.path}/#{src_file.path} > $@
          \nsub_level_dependency_files += #{output_file}
          HEREDOC
      end
    end

    def create_all_library_sources
      @project.libraries.each do |lib|
        create_library_sources(lib)
      end
    end

  end
end
