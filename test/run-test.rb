require 'test/unit'
require_relative 'test_helper'

base_dir = File.expand_path(File.join(File.dirname(__FILE__), ".."))
lib_dir  = File.join(base_dir, "lib")
test_dir = File.join(base_dir, "test")

$LOAD_PATH.unshift(lib_dir)

Test::Unit::AutoRunner.run(true, test_dir)
exit true
