class String
  def imports_library?(library_name,package_name)
    m = /\A\s*use\s+(\w+)\.(\w+)\.\S+;/.match(self)
    if m
      library_name.replace(m[1]);
      package_name.replace(m[2]);
    end
    m
  end

  def is_a_std_library?
    standard_libraries = ['std', 'ieee', 'ncutils', 'synopsys', 'cadence']
    standard_libraries.include?(self)
  end

  #Matches: for instance_label: component_name use entity library_name.entity_name(architecture_name);
  def is_a_use_entity_statement?(library_name,entity_name,architecture_name)
    m = /\A\s*for\s+\w+\s*:\s+\w+\s+use\s+entity\s+(\w+)\.(\w+)\((\w+)\)\s*;/.match(self)
    if m
      library_name.replace(m[1]);
      entity_name.replace(m[2]);
      architecture_name.replace(m[3]);
    end
    m
  end

  #Matches: for instance_label: component_name use configuration library_name.config_name;
  def is_a_use_config_statement?(library_name,config_name)
    m = /\A\s*for\s+\w+\s*:\s+\w+\s+use\s+configuration\s+(\w+)\.(\w+)\s*;/.match(self)
    if m
      library_name.replace(m[1]);
      config_name.replace(m[2]);
    end
    m
  end

  def is_a_component_definition?(component_name)
    m = /\A\s*component\s+(\w+)\s+/.match(self)
    if m
      component_name.replace(m[1]);
    end
    m
  end

  def is_an_entity_definition?(entity_name)
    m = /\A\s*entity\s+(\w+)\s+is/.match(self)
    if m
      entity_name.replace(m[1]);
    end
    m
  end

  def is_an_architecture_definition?(architecture_name,entity_name)
    m = /\A\s*architecture\s+(\w+)\s+of\s+(\w+)\s+is/.match(self)
    if m
      architecture_name.replace(m[1]);
      entity_name.replace(m[2]);
    end
    m
  end

  def is_a_package_header_definition?(package_name)
    m = /\A\s*package\s+(\w+)\s+is/.match(self)
    if m
      package_name.replace(m[1]);
    end
    m
  end

  def is_a_package_body_definition?(package_name)
    m = /\A\s*package\s+body\s+(\w+)\s+is/.match(self)
    if m
      package_name.replace(m[1]);
    end
    m
  end
end
