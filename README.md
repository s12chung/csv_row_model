# CsvRowModel [![Build Status](https://travis-ci.org/s12chung/csv_row_model.svg?branch=master)](https://travis-ci.org/s12chung/csv_row_model) [![Code Climate](https://codeclimate.com/github/s12chung/csv_row_model/badges/gpa.svg)](https://codeclimate.com/github/s12chung/csv_row_model) [![Test Coverage](https://codeclimate.com/github/s12chung/csv_row_model/badges/coverage.svg)](https://codeclimate.com/github/s12chung/csv_row_model/coverage)

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

### ImportRowModel

Automagically maps each column of a CSV row to an attribute of the `RowModel`.

```ruby
class ProjectImportRowModel < ProjectRowModel
  include CsvRowModel::Import

  # optional override
  def name
    mapped_row[:name].upcase
  end

  class << self
    # optional override
    def format_cell(cell, column_name, column_index)
      cell.to_i.to_s == cell ? cell.to_i : cell
    end
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

### ImportMapper

If the CSV row represents something complex, a `Mapper` can be used to hide CSV details.

CSV Row --is represented by--> `RowModel` --is abstracted by--> `Mapper`

```ruby
class ProjectImportMapper
  include CsvRowModel::Import::Mapper

  maps_to ProjectImportRowModel

  # shortcut to memoize operations, to minimize gem size
  # https://github.com/matthewrudy/memoist is not used,
  # but you may use it yourself
  memoize :project, :user

  def project_name
    row_model.name
  end

  protected

  def _project
    project = Project.find(row_model.id)
    project.name = row_model.name
    project
  end

  def _user
    User.find_by_email(row_model.email)
  end
end
```

Importing is the same:

```ruby
import_file = CsvRowModel::Import::File.new(file_path, ProjectImportMapper)
import_mapper = import_file.next

import_mapper.row_model # gets the row model underneath
import_mapper.context # :context, :previous, :free_previous are delegated to row_model for convenience

# the `RowModel` is still working underneath
import_mapper.project.name # => "SOME PROJECT NAME"
import_mapper.project.name == import_mapper.project_name # => true
```

## Validations

Use [`ActiveModel::Validations`](http://api.rubyonrails.org/classes/ActiveModel/Validations.html)
on your `RowModel` or `Mapper`.

## Callbacks
You can also iterate through a file with the `#each` method:

```ruby
CsvRowModel::Import::File.new(file_path, ProjectImportRowModel).each do |project_import_model|
  # the "given block"
end
```

`CsvRowModel::Import::File` can be subclassed to access
[`ActiveModel::Callbacks`](http://api.rubyonrails.org/classes/ActiveModel/Callbacks.html):

* each - `before`, `around`, or `after` the `each` method
* yield - `before`, `around`, or `after` yielding the `RowModel` to the "given block" (see Ruby code above)
* skip - `before`
* abort - `before`

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
