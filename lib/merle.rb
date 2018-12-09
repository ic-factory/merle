$:.unshift(File.expand_path("../", __FILE__))
require "merle/version"
require 'ecic'
require 'fileutils'

module Merle
  autoload :Help, "merle/help"
  autoload :Command, "merle/command"
  autoload :CLI, "merle/cli"
  autoload :VhdlReader, "merle/vhdl_reader"
  autoload :Analyzer, "merle/analyzer"
  autoload :String, "merle/string"
  autoload :Completion, "merle/completion"
  autoload :Completer, "merle/completer"
  autoload :MakefileCreator, "merle/makefile_creator"
  autoload :Printer, "merle/printer"
  autoload :FilePrinter, "merle/file_printer"
end
