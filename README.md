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

## Usage

### Basic Usage

Define your `RowModel`.
```ruby
class ProjectRowModel
  include RowModel

  # column numbers are tracked
  column :id
  column :name, heading: "Project Name" # heading defualt is `column_name.to_s.titlize`, can pass proc
end
```

#### Export

Follow [`ActiveModel::Serializer`](https://github.com/rails-api/active_model_serializers) patterns.
```ruby
class ProjectExportRowModel < ProjectRowModel
  include ExportRowModel

  # optionally define columns as such, default implementation below.
  def name
    object.name
  end
end

# export an instance
row_model = ProjectExportRowModel.new(project)
row_model.headings # => ["Id", "Project Name"]
row_model.export(without_headings: true) # without_headings default default is false

# export a colection
ExportRowModelCollection.new(projects, row_model: ProjectExportRowModel).export
```

#### Import

You can map each column to an attribute of a single instance of a model.
```ruby
class ProjectImportRowModel < ProjectRowModel
  include ImportRowModel

  # optionally match columns via headings instead of column number, optional proc. default proc shown.
  match_headings ->(column_heading, source_heading) { column_heading == read_csv_header }

  # optional, overrides the default below
  def name
    mapped_row[:name].upcase
  end

  # optional, default always true
  def matched_instance?(instance)
    self.id == instance.id
  end
end

# Import an instance
row_model = ProjectImportRowModel.new(file)
row_model.source_row # => ["1", "Some Project Name"]
row_model.name # => "SOME PROJECT NAME"
row_model.import(project)
project.name # => "SOME PROJECT NAME"
```

__Thinking about how to do this. The difference between importing and exporting is that finding and modifying is harder---you have to match the record and modifying depends on order....__
```ruby
class ProjectImportRowMapper < ImportRowMapper
  def project
    project = Project.find(row_model.id)
    row_model.import(project)
  end

  def child_project
    .child_project
  end

  # define whatever methods you want
end

ProjectImportRowMapper.new(ProjectImportRowModel.new(file)).child_project # => `Project` object that's the `child_project`
```
### Validations

Use `ActiveModel::Validations` to validate the row, all of these can be implemented in `RowModel`, `ExportRowModel` or `ImportRowModel`
```ruby
# ActiveModel::Validations
validates :name, presence: true

# to handle collections, define when to skip a row or abort the collection. default implementations below
def skip?
  errors?
end

def abort?
  match_headings? ? !headings_matched? : false
end
```
Then you can call.
```ruby
row_model.valid?
row_model.errors
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/csv_row_model/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
