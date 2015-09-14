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

# RowModel

Define your `RowModel`'s schema.

```ruby
class ProjectRowModel
  include CsvRowModel::Model

  # column indices are tracked with each call
  column :id
  column :name
  column :owner_id, header: 'Project Manager' # optional header String, that allows to modify the header of the colmnun
end
```

This schema can be used for both Import and Export.

## Import

Automagically maps each column of a CSV row to an attribute of the `RowModel`.

```ruby
class ProjectImportRowModel < ProjectRowModel
  include CsvRowModel::Import

  def name
    # mapped_row is raw
    # the calculated original_attribute[:name] is accessible as well
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

## Presenter
For complex rows, you can wrap your `RowModel` with a presenter:

```ruby
class ProjectImportRowModel < ProjectRowModel
  include CsvRowModel::Import

  # same as above

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

## Children

Child `RowModel` relationships can also be defined:

```ruby
class UserImportRowModel
  include CsvRowModel::Model
  include CsvRowModel::Import

  column :id
  column :name
  column :email

  # uses ProjectImportRowModel#valid? to detect the child row
  has_many :projects, ProjectImportRowModel
end

import_file = CsvRowModel::Import::File.new(file_path, UserImportRowModel)
row_model = import_file.next
row_model.projects # => [<ProjectImportRowModel>, ...]
```

## Column Options
### Default Attributes
For `Import`, `default_attributes` are calculated as thus:
- `format_cell`
- if `value_from_format_cell.blank?`, `default_lambda.call` or nil
- otherwise, `parse_lambda.call`

#### Format Cell
Override the `format_cell` method to clean/format every cell:
```ruby
class ProjectImportRowModel < ProjectRowModel
  include CsvRowModel::Import
  class << self
    def format_cell(cell, column_name, column_index)
      cell = cell.strip
      cell.to_i.to_s == cell ? cell.to_i : cell
    end
  end
end
```

#### Default
Called when `format_cell` is `value_from_format_cell.blank?`, it sets the default value of the cell:
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

`DefaultChangeValidator` is provided to allows to add warnings when defaults or set:

```ruby
class ProjectImportRowModel
  include CsvRowModel::Model
  include CsvRowModel::Input

  column :id, default: 1

  warnings do
    validates :id, default_change: true
    # validates :id, presence: true, works too. See ActiveWarnings gem for more.
  end
end

row_model = ProjectImportRowModel.new([""])

row_model.unsafe? # => true
row_model.has_warnings? # => true, same as `#unsafe?`
row_model.warnings.full_messages # => ["Id changed by default"]
```

See [Validations](#validations) for more.

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

## Validations

Use [`ActiveModel::Validations`](http://api.rubyonrails.org/classes/ActiveModel/Validations.html)
on your `RowModel` or `Mapper`.

Included is [`ActiveWarnings`](https://github.com/s12chung/active_warnings) on `Model` and `Mapper` for warnings
(such as setting defaults), but not errors (which by default results in a skip).

`RowModel` has two validation layers on the `csv_string_model` (a model of `#mapped_row` with `::format_cell` applied) and itself:

```ruby
class ProjectRowModel
  include CsvRowModel::Model
  include CsvRowModel::Import

  column :id, type: Integer

  # this is applied to the parsed CSV on the model
  validates :id, numericality: { greater_than: 0 }

  csv_string_model do
    # this is applied before the parsed CSV on csv_string_model
    validates :id, integer_format: true, allow_blank: true
  end
end

# Applied to the String
ProjectRowModel.new(["not_a_number"])
row_model.valid? # => false
row_model.errors.full_messages # => ["Id is not a Integer format"]

# Applied to the parsed Integer
row_model = ProjectRowModel.new(["-1"])
row_model.valid? # => false
row_model.errors.full_messages # => ["Id must be greater than 0"]
```

Notice that there are validators given for different types: `Boolean`, `Date`, `Float`, `Integer`:

```ruby
class ProjectRowModel
  include CsvRowModel::Model

  # the :validate_type option does the commented code below.
  column :id, type: Integer, validate_type: true

  # csv_string_model do
  #   validates :id, integer_format: true, allow_blank: true
  # end
end
```


## Callbacks
`CsvRowModel::Import::File` can be subclassed to access
[`ActiveModel::Callbacks`](http://api.rubyonrails.org/classes/ActiveModel/Callbacks.html).

You can iterate through a file with the `#each` method, which calls `#next` internally:

```ruby
CsvRowModel::Import::File.new(file_path, ProjectImportRowModel).each do |project_import_model|
end
```

Within `#each`, **Skips** and **Aborts** will be done via the `skip?` or `abort?` method on the row model,
allowing the following callbacks:

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

### Export RowModel

Maps each attribute of the `RowModel` to a column of a CSV row.

```ruby
class ProjectExportRowModel < ProjectRowModel
  include CsvRowModel::Export

  # Optionally it's possible to override the attribute method, by default it
  # does source_model.public_send(attribute)
  def name
    "#{source_model.id} - #{source_model.name}"
  end
end
```

### Export SingleModel

Maps each attribute of the `RowModel` to a row on the CSV.

```ruby
class ProjectExportRowModel < ProjectRowModel
  include CsvRowModel::Export
  include CsvRowModel::Export::SingleModel
end
```

And to export:

```ruby
export_file = CsvRowModel::Export::File.new(ProjectExportRowModel)
export_file.generate do |csv|
  csv.append_model(project)
end
export_file.file # returns the TempFile on disk
export_file.to_s # the string representation
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