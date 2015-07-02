# CsvRowModel

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
  include CsvRowModel::Base

  # column numbers are tracked
  column :id
  column :name
  column :email
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
import_file = CsvRowModel::ImportFile.new(file_path, ProjectImportRowModel)
row_model = import_file.next

row_model.header # => ["id", "name", "email"]

row_model.source_row # => ["1", "Some Project Name", "blotz@hotzmail.com"]
row_model.mapped_row # => { id: "1", name: "Some Project Name", email: "blotz@hotzmail.com" }

row_model.id # => 1
row_model.name # => "SOME PROJECT NAME"
```

`ImportFile` also provides the `RowModel` with the previous `RowModel` instance:
```
import_file = CsvRowModel::ImportFile.new(file_path, ProjectImportRowModel)
row_model = import_file.next
row_model = import_file.next

row_model.previous # => <ProjectImportRowModel instance>
row_model.previous.previous # => nil, save memory by avoiding a linked list
```

### Import Children

Child `RowModel` relationships can also be defined:

```ruby
class UserImportRowModel
  include CsvRowModel::Base
  include CsvRowModel::Import

  # override ProjectImportRowModel#valid? to help detect the child row
  has_many :projects, ProjectImportRowModel
end

import_file = CsvRowModel::ImportFile.new(file_path, ProjectImportRowModel)
row_model = import_file.next
row_model.projects # => [<ProjectImportRowModel>, ...] if ProjectImportRowModel#valid? == true
```

### ImportMapper

If the CSV row represents something complex, a `Mapper` can be used to hide CSV details.

CSV Row --is represented by--> `RowModel` --is abstracted by--> `Mapper`

```ruby
class ProjectImportMapper
  include CsvRowModel::ImportMapper

  # shortcut to memoize operations, to minimize gem size
  # https://github.com/matthewrudy/memoist is not used,
  # but you may use it yourself
  memoize :project, :user

  def project_name
    row_model.name
  end

  private

  def _project
    project = Project.find(row_model.id)
    project.name = row_model.name
    project
  end

  def _user
    User.find_by_email(row_model.email)
  end

  class << self
    def row_model_class
      ProjectImportRowModel
    end
  end
end
```

Importing is the same:
```ruby
import_file = CsvRowModel::ImportFile.new(file_path, ProjectImportMapper)
import_mapper = import_file.next

import_mapper.row_model # gets the row model underneath
import_mapper.context # :context, :previous, :free_previous are delegated to row_model for convenience

# the `RowModel` is still working underneath
import_mapper.project.name # => "SOME PROJECT NAME"
import_mapper.project.name == import_mapper.project_name # => true
```