
module Merle

  class Analyzer
    require 'set'
    require 'pathname'

    def self.load(library_name, project_root, filename)
      self.new(library_name, project_root, filename).read
    end

    def initialize (library_name, project_root, filename)
      @library_name = library_name.downcase
      #TBA: Makby add an option to control whether an absolute path or a path
      #relative to the project must be used for the source file.
#      @src_filename = File.expand_path(filename)
      project_root = File.expand_path(project_root)
      filename = File.expand_path(filename)
      @src_filename = Pathname.new(filename).relative_path_from(Pathname.new(project_root))

      base_obj_file = get_base_obj_file(filename,project_root)
      #TBA: replace src with obj - and make sure the path is
      #relative to the project and include a $(project_root)
      #Make variable!
#      dependency_filename = "#{base_obj_file}.d"
      @object_filename = "#{base_obj_file}.o"
      @dependable_target_files = Set.new
#      @dependable_target_files.add(dependency_filename)
      @dependable_target_files.add(@object_filename)
      @vhdl_reader = VhdlReader.new(filename, library_name)
    end


    def to_make
      file_dependencies
      puts ""
      library_dependencies
    end

    def library_dependencies
      path_prefix = "$(path_prefix)"
      #Library level dependencies:
      puts "#{path_prefix}/#{@library_name}.lib : " + @vhdl_reader.required_libraries.map{ |lib| "#{path_prefix}/#{lib}.lib"}.join(' ')
    end

    def file_dependencies
      path_prefix = "$(path_prefix)"
      #Define the target for compiling the VHDL file:
      puts "#{@object_filename} : "
      puts "\t@set -euo pipefail;\\"
      puts "\tmkdir -p $(@D);\\"
      puts "\tcd $(project_root);\\"
      puts "\techo 'Compiling #{@src_filename} ...';\\"
      puts "\techo 'compile --lib=#{@library_name} #{@src_filename}';\\"
      puts "\ttouch $@;"

      @vhdl_reader.provided_package_headers.each do |pkg_head|
        puts "\n#{path_prefix}/#{pkg_head}.header : #{@object_filename}"
        puts "\t@set -e; touch $@;"
      end

      @vhdl_reader.provided_components.each do |comp|
        puts "\n#{path_prefix}/#{comp} : #{@object_filename}"
        puts "\t@set -e; touch $@;"
      end

      @vhdl_reader.provided_entities.each do |ent|
        puts "\n#{path_prefix}/#{ent} : #{@object_filename}"
        puts "\t@set -e; touch $@;"
      end

      @vhdl_reader.provided_architectures.each do |arc|
        puts "\n#{path_prefix}/#{arc} : #{@object_filename}"
        puts "\t@set -e; touch $@;"
        #Make sure the architecture is recompiled if the entity changes:
        entity_symbol = VhdlReader.entity(arc)
        puts "\n#{@object_filename} : #{path_prefix}/#{entity_symbol}" unless @vhdl_reader.includes_entity_for?(arc)
      end
      #Dependencies internal to the library:
      #Use a separate target that defines when all files of a library has
      #been compiled. This is to avoid having source file dependencies at
      #library level.
      puts "\n#{path_prefix}/#{@library_name}.lib.o : #{@object_filename} "

      external_required_packages = @vhdl_reader.required_packages - @vhdl_reader.provided_package_headers
      if external_required_packages.length > 0
        puts "\n#{@object_filename} : " + external_required_packages.map{ |pkg| "#{path_prefix}/#{pkg}"}.join(' ')
      end

      #Print all targets that depend on the source file:
      puts "\n" + @dependable_target_files.to_a.join(' ') + " : #{@src_filename}"
    end


    def read
      @vhdl_reader.read
      self
    end

    private

      def get_base_obj_file(filename,project_root)
        relative_path_from_project = Pathname.new(filename).relative_path_from(Pathname.new(project_root))
        m = /\A\.\./.match(relative_path_from_project.to_s)
        if m
          #The source file is placed outside the project root, so set the output
          #diretory by concatenating the 'obj' folder within the project root
          #folder with the absolute path of the source file.
          File.join('$(project_root)/obj', src_base_path)
        else
          #The source file is placed within a project. Set the output directory
          #by replacing any /src/ folders with /obj/ and prepend the project root
          #folder.
          File.join('$(project_root)', relative_path_from_project).sub(/\/src\//, '/obj/')
        end
      end

  end
end
