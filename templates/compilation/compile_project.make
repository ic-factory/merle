#GNU Makefile for compiling files in an ECIC project
SHELL := /bin/sh
.SUFFIXES: #Clear the suffix list:

#Set default Make target to 'all':
.PHONY: all
all :

#Avoid implicit rule search for this Make file:
./compile_all.make : ;

path_prefix := $(project_root_dir)/obj/compilation/$(scope)

#Create rule for how to generate obj/config/libraries.make and then include it:
$(path_prefix)/libraries.make : $(project_root_dir)/src/config/libraries.rb
	@mkdir -p $(@D);\
	echo "Generating $@";\
	vhdl_dependency init_makefiles --scope=$(scope) $(path_prefix)

####TBA	vhdl_dependency library_list > $@

#$(warning Including $(project_root_dir)/obj/config/libraries.make)
-include $(path_prefix)/libraries.make

#TBA: What mappens if 'library_sources' is empty?
#$(warning Including library_sources: $(library_sources))
-include $(library_sources)

#$(warning Including library_level_dependency_files: $(library_level_dependency_files))
-include $(library_level_dependency_files)

### include $(sub_level_dependency_files)

#$(warning all_libraries = $(all_libraries))

#$(path_prefix)/%.lib
#Note: 'all_libraries' is a list of .lib targets
all: $(all_libraries)
	@echo "Done compiling all libraries"

.PHONY: $(all_libraries)

$(all_libraries) :
		@set -e;\
		 echo "Checking $@";\

#TBA: $(project_root_dir)/obj/config/libraries.make must probably
#include variables that can be used to map a library name to a directory path.
#This is to be able to determine which sub_level_dependency_file must be sourced
#by 'compile_library' Make file.
#	$(MAKE) -f compile_library --jobs=1 $(path_prefix)/%.lib.o
