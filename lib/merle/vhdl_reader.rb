
module Merle

  class VhdlReader
    require 'set'

    attr_reader :required_packages, :provided_package_headers, :provided_components, :provided_entities, :provided_architectures, :required_packages, :required_libraries
#    :provided_package_bodies

    def self.load(filename,library_name)
      self.new(filename, library_name).read
    end

    def self.entity(arc_symbol)
      str = arc_symbol.to_s
      m = /\A(\w+).lib\.(\w+)\.\w+\.arc/.match(str)
      if m
        return VhdlReader.entity_symbol(m[1], m[2])
      else
        raise "Could not determine entity symbol from #{str}"
      end
    end

    def self.entity_symbol(library_name, entity_name)
      "#{library_name}.lib.#{entity_name}.ent".to_sym
    end


    def initialize (filename, library_name)
      @src_filename = filename
      @library_name = library_name.downcase
      @required_packages = Set.new
      @required_libraries = Set.new
      @provided_package_headers = Set.new
      @provided_package_bodies = Set.new
      @provided_components = Set.new
      @provided_entities = Set.new
      @provided_architectures = Set.new
    end

    def read
#      puts "#Analyzing #{@src_filename} ..."
      raise ArgumentError, "File does not exist: #{@src_filename}" unless File.file?(@src_filename)
      library_name   = String.new
      package_name   = String.new
      component_name = String.new
      entity_name    = String.new
      config_name    = String.new
      architecture_name = String.new
      File.readlines(@src_filename).each do |line|
        line.downcase!
        if line.imports_library?(library_name,package_name)
          unless library_name.is_a_std_library?
            @required_packages  << "#{library_name}.lib.#{package_name}.pkg".to_sym #if library_name == @library_name
            @required_libraries << library_name.to_sym unless library_name == @library_name
          end
        elsif line.is_an_architecture_definition?(architecture_name,entity_name)
          @provided_architectures << architecture_symbol(@library_name, entity_name, architecture_name)
        elsif line.is_an_entity_definition?(entity_name)
          @provided_entities << self.class.entity_symbol(@library_name, entity_name)
        elsif line.is_a_component_definition?(component_name)
          @provided_components << "#{@library_name}.lib.#{component_name}.comp".to_sym
        elsif line.is_a_package_header_definition?(package_name)
          @provided_package_headers << "#{@library_name}.lib.#{package_name}.pkg".to_sym
        elsif line.is_a_package_body_definition?(package_name)
          @provided_package_bodies << "#{@library_name}.lib.#{package_name}.pkg".to_sym
        end
      end
      self
    end

    def includes_entity_for?(architecture)
      entity_symbol = VhdlReader.entity(architecture)
      @provided_entities.include?(entity_symbol)
    end

    private

      def architecture_symbol(library_name, entity_name, architecture_name)
        "#{library_name}.lib.#{entity_name}.#{architecture_name}.arc".to_sym
      end
  end
end
