module Merle
  class CLI < Command

    class << self
      def help(shell, subcommand = false)
        shell.say "Usage: merle COMMAND [ARGS]"
        shell.say ""
        super
        shell.say "To get more help on a specific command, try 'merle help [COMMAND]'"
      end
    end

    check_unknown_options!

    #Make sure to return non-zero value if an error is thrown.
    def self.exit_on_failure?
      true
    end

    desc "version", "prints version"
    def version
      puts VERSION
    end

    desc "to_make LIBRARY_NAME PROJECT_ROOT FILE_NAME", "Analyze a VHDL file and print a GNU Make dependency file"
    def to_make(library_name, project_root, filename)
      begin
        Analyzer.load(library_name, project_root, filename).to_make
      rescue ArgumentError => exc
        shell.error set_color(exc.message, Thor::Shell::Color::RED)
        exit(3)
      end
    end

    desc "file_dependencies LIBRARY_NAME PROJECT_ROOT FILE_NAME", "Analyze a VHDL file and print file dependencies"
    def file_dependencies(library_name, project_root, filename)
      begin
        Analyzer.load(library_name, project_root, filename).file_dependencies
      rescue ArgumentError => exc
        shell.error set_color(exc.message, Thor::Shell::Color::RED)
        exit(3)
      end
    end

    desc "library_dependencies LIBRARY_NAME PROJECT_ROOT FILE_NAME", "Analyze a VHDL file and print library dependencies"
    def library_dependencies(library_name, project_root, filename)
      begin
        Analyzer.load(library_name, project_root, filename).library_dependencies
      rescue ArgumentError => exc
        shell.error set_color(exc.message, Thor::Shell::Color::RED)
        exit(3)
      end
    end

    desc "library_list", "Print list of libraries in a GNU Make format"
    option :scope, :type => :string, :banner => 'SCOPE', :desc => 'Specify the scope from which libraries and files must be selected'
    def library_list
      begin
        root_dir = ::Ecic::Project::root
        if root_dir.nil?
          shell.error set_color("You must be within an ECIC project before calling this command",Thor::Shell::Color::RED)
          exit(4)
        end
        opt = {"scope" => ''}.merge(options)
        makefile_creator = MakefileCreator.new(root_dir,opt['scope'],nil).load_libraries
        makefile_creator.create_library_list

      rescue ArgumentError => exc
        shell.error set_color(exc.message, Thor::Shell::Color::RED)
        exit(5)
      end
    end


    desc "library_sources LIBRARY_NAME", "Print make syntax to load dependency files for each VHDL source"
    option :scope, :type => :string, :banner => 'SCOPE', :desc => 'Specify the scope from which files must be selected'
    def library_sources(library_name)
      begin
        root_dir = ::Ecic::Project::root
        if root_dir.nil?
          shell.error set_color("You must be within an ECIC project before calling this command",Thor::Shell::Color::RED)
          exit(4)
        end
        opt = {"scope" => ''}.merge(options)
        makefile_creator = MakefileCreator.new(root_dir,opt['scope'],nil).load_libraries
        makefile_creator.create_library_sources(library_name)

#        say '#include somefile.d := ' + project.libraries.map{ |lib| lib.to_s }.join(" ")
      rescue ArgumentError => exc
        shell.error set_color(exc.message, Thor::Shell::Color::RED)
        exit(5)
      end
    end

    desc "init_makefiles OUTPUT_DIRECTORY", "Create initial version of various Make files that are required during compilation"
    option :scope, :type => :string, :banner => 'SCOPE', :desc => 'Specify the scope from which source files must be selected'
    def init_makefiles(output_directory)
      begin
        root_dir = ::Ecic::Project::root
        if root_dir.nil?
          shell.error set_color("You must be within an ECIC project before calling this command",Thor::Shell::Color::RED)
          exit(6)
        end
        opt = {"scope" => ''}.merge(options)
        raise ArgumentError, "#{output_directory} directory does not exist. Please create it and try again." unless File.directory?(output_directory)
        makefile_creator = MakefileCreator.new(root_dir,opt['scope'],output_directory).load_libraries
        makefile_creator.create_library_list
        makefile_creator.load_all_source_files
        makefile_creator.create_all_library_sources
#        makefile_creator.create_all_source_makefiles
      rescue ArgumentError, IOError, Errno::ENOENT => exc
        shell.error set_color(exc.message, Thor::Shell::Color::RED)
        exit(5)
      end
    end
  end
end
