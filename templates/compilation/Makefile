#Top-level GNU Makefile for compiling files in an ECIC project
SHELL := /bin/sh
.SUFFIXES: #Clear the suffix list:

#Options for 'compile' target:
#	  scope : Specifies the scope that must be applied when cin which source Set to

#Set default Make target to 'compile':
compile :

#Avoid implicit rule search for this Make file:
./Makefile : ;

project_root_dir := $(shell ecic project root)

.PHONY: compile
compile:
	@$(MAKE) --no-builtin-rules --jobs=500 -f compile_project.make project_root_dir=$(project_root_dir) scope=$(scope);\
	echo "Project has been compiled"

.PHONY: clean-all
clean-all:
	@rm -rf $(project_root_dir)/obj/compilation
