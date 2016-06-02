# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'csv_row_model/version'

Gem::Specification.new do |spec|
  spec.name          = "csv_row_model"
  spec.version       = CsvRowModel::VERSION
  spec.authors       = ["Steve Chung", 'Joel AZEMAR']
  spec.email         = ["hello@stevenchung.ca", 'joel.azemar@gmail.com']

  spec.summary       = "Import and export your custom CSVs with a intuitive shared Ruby interface."
  spec.homepage      = "https://github.com/s12chung/csv_row_model"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activemodel", "~> 4.2"
  spec.add_dependency "active_warnings", "~> 0.1.2"
  spec.add_dependency "inherited_class_var", ">= 0.2.1"
end
