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

Define your `RowModel`.

```ruby
class ProjectRowModel
  include CsvRowModel::Model

  # column numbers are tracked
  column :id, type: Integer # optional type parsing, or use the :parse option with a Proc
  column :name
end
```

### Import RowModel

Automagically maps each column of a CSV row to an attribute of the `RowModel`.

```ruby
class ProjectImportRowModel < ProjectRowModel
  include CsvRowModel::Import

  def name
    check_invalid_attributes(:name) # needed for `Mapper#dependent_attributes`
    mapped_row[:name].upcase # original_attribute[:name] is accessible as well
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

```
import_file = CsvRowModel::Import::File.new(file_path, ProjectImportRowModel)
row_model = import_file.next
row_model = import_file.next

row_model.previous # => <ProjectImportRowModel instance>
row_model.previous.previous # => nil, save memory by avoiding a linked list
```

### Import Children

Child `RowModel` relationships can also be defined:

```ruby
class UserImportRowModel
  include CsvRowModel::Model
  include CsvRowModel::Import

  column :id
  column :name
  column :email

  # uses ProjectImportRowModel#valid? to detect the child row
  # use validations or overriding to do this
  has_many :projects, ProjectImportRowModel
end

import_file = CsvRowModel::Import::File.new(file_path, UserImportRowModel)
row_model = import_file.next
row_model.projects # => [<ProjectImportRowModel>, ...] if ProjectImportRowModel#valid? == true
```

### Import Mapper
`RowModel` represents a row, but rows can map to other objects. For instance:

```ruby
class ProjectImportMapper
  include CsvRowModel::Import::Mapper

  maps_to ProjectImportRowModel

  attribute :project, dependencies: [:id, :name] do
    project = Project.where(id: row_model.id).first

    # project not found, invalid.
    return unless project

    project.name = row_model.name
    project
  end
end
```
There are two layers:

1. `RowModel` - represents the CSV row and validates CSV syntax
2. `Mapper` - defines the relationship between `RowModel` and the database, so it validates database operations

In the example, the `attribute` method defines a method `project`, which is memoized by default (turn off with `:memoize` option).
Also note the `:dependencies` `id` and `name`, which correspond to `row_model.id/name`. When any of the dependencies are `invalid?`:

  1. The attribute block is not called and the attribute returns `nil`.
  2. Attribute errors are filtered based on the dependencies. In this case, if `row_model.id/name` are `invalid?`, then
  the `:project` key is removed from the errors, resulting in: `import_mapper.errors.keys # => [:id, :name]`.

Also, importing is the same:

```ruby
import_file = CsvRowModel::Import::File.new(file_path, ProjectImportMapper)
import_mapper = import_file.next

import_mapper.row_model # gets the row model underneath
import_mapper.context # delegate to all row_model methods, EXCEPT column_name methods (to keep separatation)

# the `RowModel` is still working underneath
import_mapper.project.name # => "SOME PROJECT NAME"
```

## Column Options
### Default Attributes
For `Import`, `default_attributes` are calculated as thus:
- `format_cell`
- if `value_form_format_cell.blank?`, `default_lambda.call`
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
Called when `format_cell` is `blank?`, it sets the default value of the cell:
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

* yield - `before`, `around`, or `after` the iteration yield
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