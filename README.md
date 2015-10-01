# CsvRowModel [![Build Status](https://travis-ci.org/FinalCAD/csv_row_model.svg?branch=master)](https://travis-ci.org/FinalCAD/csv_row_model) [![Code Climate](https://codeclimate.com/github/FinalCAD/csv_row_model/badges/gpa.svg)](https://codeclimate.com/github/FinalCAD/csv_row_model) [![Test Coverage](https://codeclimate.com/github/FinalCAD/csv_row_model/badges/coverage.svg)](https://codeclimate.com/github/FinalCAD/csv_row_model/coverage)

Import and export your custom CSVs with a intuitive shared Ruby interface.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'csv_row_model'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install csv_row_model

## RowModel

Define your `RowModel`'s schema.

```ruby
class ProjectRowModel
  include CsvRowModel::Model

  # column indices are tracked with each call
  column :id, type: Integer
  column :name
end
```

This schema can be used for both Import and Export.

## Export

Maps each attribute of the `RowModel` to a column of a CSV row.

```ruby
class ProjectExportRowModel < ProjectRowModel
  include CsvRowModel::Export

  # Optional Override
  def name
    "#{source_model.id} - #{source_model.name}" # default implementation: source_model.name
  end
end
```

And to export:

```ruby
export_file = CsvRowModel::Export::File.new(ProjectExportRowModel)
export_file.generate { |csv| csv.append_model(project) }
export_file.file # => <Tempfile>
export_file.to_s # => export_file.file.read
```

### FileModel
Maps each attribute of the `RowModel` to a row on the CSV (a csv file is a now a model). More documentation is needed...

```ruby
class ProjectExportRowModel < ProjectRowModel
  include CsvRowModel::Export
  include CsvRowModel::Export::SingleModel
end
```

### Header Value
To generate a header value, the following pseudocode is executed:
```ruby
def header(column_name)
  # 1. Header Option
  header = options(column_name)[:header]

  # 2. format_header
  header || format_header(column_name)
end
```

#### Header Option
Specify the header manually:
```ruby
class ProjectRowModel
  include CsvRowModel::Model
  column :name, header: "NAME"
end
```

#### Format Header
Override the `format_header` method to format column header names:
```ruby
class ProjectExportRowModel < ProjectRowModel
  include CsvRowModel::Export
  class << self
    def format_header(column_name)
      column_name.to_s.titleize
    end
  end
end
```

## Import

Maps each column of a CSV row to an attribute of the `RowModel`.

```ruby
class ProjectImportRowModel < ProjectRowModel
  include CsvRowModel::Import

  def name
    mapped_row[:name].upcase
  end
end
```

And to import:

```ruby
import_file = CsvRowModel::Import::File.new(file_path, ProjectImportRowModel)
row_model = import_file.next

row_model.header # => ["id", "name"]

row_model.source_row # => ["1", "Some Project Name"]
row_model.mapped_row # => { id: "1", name: "Some Project Name" }

row_model.id # => 1
row_model.name # => "SOME PROJECT NAME"
```

`Import::File` also provides the `RowModel` with the previous `RowModel` instance:

```ruby
row_model.previous # => <ProjectImportRowModel instance>
row_model.previous.previous # => nil, save memory by avoiding a linked list
```

See [Attribute Values](#attribute-values) for more on configuring and overriding Import attribute values.

### Children

Child `RowModel` relationships can also be defined:

```ruby
class UserImportRowModel
  include CsvRowModel::Model
  include CsvRowModel::Import

  column :id, type: Integer
  column :name
  column :email

  # uses ProjectImportRowModel#valid? to detect the child row
  has_many :projects, ProjectImportRowModel
end

import_file = CsvRowModel::Import::File.new(file_path, UserImportRowModel)
row_model = import_file.next
row_model.projects # => [<ProjectImportRowModel>, ...]
```

### Layers
For complex `RowModel`s there are different layers you can work with:
```ruby
import_file = CsvRowModel::Import::File.new(file_path, ProjectImportRowModel)
row_model = import_file.next

# the three layers:
# 1. csv_string_model - represents the row BEFORE parsing (attributes are always strings)
row_model.csv_string_model

# 2. RowModel - represents the row AFTER parsing
row_model

# 3. Presenter - an abstraction of a row
row_model.presenter
```

#### CsvStringModel
The `CsvStringModel` represents a row before parsing to add parsing validations.

```ruby
class ProjectRowModel
  include CsvRowModel::Model
  include CsvRowModel::Import

  # Note the type definition here for parsing
  column :id, type: Integer

  # this is applied to the parsed CSV on the model
  validates :id, numericality: { greater_than: 0 }

  csv_string_model do
    # define your csv_string_model here

    # this is applied BEFORE the parsed CSV on csv_string_model
    validates :id, presense: true

    def random_method; "Hihi" end
  end
end

# Applied to the String
ProjectRowModel.new([""])
csv_string_model = row_model.csv_string_model
csv_string_model.random_method => "Hihi"
csv_string_model.valid? => false
csv_string_model.errors.full_messages # => ["Id can't be blank'"]

# Errors are propagated for simplicity
row_model.valid? # => false
row_model.errors.full_messages # => ["Id can't be blank'"]

# Applied to the parsed Integer
row_model = ProjectRowModel.new(["-1"])
row_model.valid? # => false
row_model.errors.full_messages # => ["Id must be greater than 0"]
```

Note that `CsvStringModel` validations are calculated after [Format Cell](#format-cell).

#### Presenter
For complex rows, you can wrap your `RowModel` with a presenter:

```ruby
class ProjectImportRowModel < ProjectRowModel
  include CsvRowModel::Import

  presenter do
    # define your presenter here

    # this is shorthand for the psuedo_code:
    # def project
    #  return if row_model.id.invalid? || row_model.name.invalid?
    #
    #  # turn off memoziation with `memoize: false` option
    #  @project ||= __the_code_inside_the_block__
    # end
    #
    # and the psuedo_code:
    # def valid?
    #   super # calls ActiveModel::Errors code
    #   errors.delete(:project) if row_model.id.invalid? || row_model.name.invalid?
    #   errors.empty?
    # end
    attribute :project, dependencies: [:id, :name] do
      project = Project.where(id: row_model.id).first

      # project not found, invalid.
      return unless project

      project.name = row_model.name
      project
    end
  end
end

# Importing is the same
import_file = CsvRowModel::Import::File.new(file_path, ProjectImportRowModel)
row_model = import_file.next
presenter = row_model.presenter

presenter.row_model # gets the row model underneath
import_mapper.project.name == presenter.row_model.name # => "SOME PROJECT NAME"
```

The presenters are designed for another layer of validation---such as with the database.

Also, the `attribute` defines a dynamic `#project` method that:

1. Memoizes by default, turn off with `memoize: false` option
2. All errors of `row_model` are propagated to the presenter when calling `presenter.valid?`
3. Handles dependencies. When any of the dependencies are `invalid?`:
  - The attribute block is not called and the attribute returns `nil`.
  - `presenter.errors` for dependencies are cleaned. For the example above, if `row_model.id/name` are `invalid?`, then
the `:project` key is removed from the errors, so: `import_mapper.errors.keys # => [:id, :name]`

### Attribute Values
To generate a attribute value, the following pseudocode is executed:

```ruby
def original_attribute(column_name)
  # 1. Get the raw CSV string value for the column
  value = mapped_row[column_name]

  # 2. Clean or format each cell
  value = self.class.format_cell(value)

  if value.present?
    # 3a. Parse the cell value (which does nothing if no parsing is specified)
    parse(value)
  elsif default_exists?
    # 3b. Set the default
    default_for_column(column_name)
  end
end

def original_attributes; @original_attributes ||= { id: original_attribute(:id) } end

def id; original_attribute[:id] end
```

#### Format Cell
Override the `format_cell` method to clean/format every cell:
```ruby
class ProjectImportRowModel < ProjectRowModel
  include CsvRowModel::Import
  class << self
    def format_cell(cell, column_name, column_index)
      cell = cell.strip
      cell.blank? ? nil : cell
    end
  end
end
```

#### Type
Automatic type parsing.

```ruby
class ProjectImportRowModel < ProjectRowModel
  include CsvRowModel::Import

  column :id, type: Integer
  column :name, parse: ->(original_string) { parse(original_string) }

  def parse(original_string)
    "#{id} - #{original_string}"
  end
end
```

There are validators for different types: `Boolean`, `Date`, `Float`, `Integer`. See [Validations](#validations) for more.

#### Default
Sets the default value of the cell:
```ruby
class ProjectImportRowModel < ProjectRowModel
  include CsvRowModel::Import

  column :id, default: 1
  column :name, default: -> { get_name }

  def get_name; "John Doe" end
end
row_model = ProjectImportRowModel.new(["", ""])
row_model.id # => 1
row_model.name # => "John Doe"
row_model.default_changes # => { id: ["", 1], name: ["", "John Doe"] }
```

`DefaultChangeValidator` is provided to allows to add warnings when defaults are set. See [Validations](#default-changes) for more.

### Validations

Use [`ActiveModel::Validations`](http://api.rubyonrails.org/classes/ActiveModel/Validations.html) the `RowModel`'s [Layers](#layers).
Please read [Layers](#layers) for more information.

Included is [`ActiveWarnings`](https://github.com/s12chung/active_warnings) on `Model` and `Mapper` for warnings.


#### Type Format
Notice that there are validators given for different types: `Boolean`, `Date`, `Float`, `Integer`:

```ruby
class ProjectRowModel
  include CsvRowModel::Model

  column :id, type: Integer, validate_type: true

  # the :validate_type option is the same as:
  # csv_string_model do
  #   validates :id, integer_format: true, allow_blank: true
  # end
end

ProjectRowModel.new(["not_a_number"])
row_model.valid? # => false
row_model.errors.full_messages # => ["Id is not a Integer format"]
```

#### Default Changes
[Default Changes](#default) are tracked within [`ActiveWarnings`](https://github.com/s12chung/active_warnings).

```ruby
class ProjectImportRowModel
  include CsvRowModel::Model
  include CsvRowModel::Input

  column :id, default: 1

  warnings do
    validates :id, default_change: true
  end
end

row_model = ProjectImportRowModel.new([""])

row_model.unsafe? # => true
row_model.has_warnings? # => true, same as `#unsafe?`
row_model.warnings.full_messages # => ["Id changed by default"]
row_model.default_changes # => { id: ["", 1] }
```

### Skip and Abort
You can iterate through a file with the `#each` method, which calls `#next` internally.
`#next` will always return the next `RowModel` in the file. However, you can implement skips and
abort logic:

```ruby
class ProjectImportRowModel
  # always skip
  def skip?
    true # original implementation: !valid? || presenter.skip?
  end
end

CsvRowModel::Import::File.new(file_path, ProjectImportRowModel).each do |project_import_model|
  # never yields here
end
```

### Callbacks
`CsvRowModel::Import::File` can be subclassed to access
[`ActiveModel::Callbacks`](http://api.rubyonrails.org/classes/ActiveModel/Callbacks.html).

* yield - `before`, `around`, or `after` the iteration yield (skips)
* next - `before`, `around`, or `after` the each change in `current_row_model` (does not skip)
* skip - `before`
* abort - `before`

and implement the callbacks:
```ruby
class ImportFile < CsvRowModel::Import::File
  around_yield :logger_track
  before_skip :track_skip

  def logger_track(&block)
    ...
  end

  def track_skip
    ...
  end
end
```