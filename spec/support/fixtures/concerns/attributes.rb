class BasicAttribute < CsvRowModel::Model::Attribute
  def value
    source_value
  end

  def source_value
    row_model.public_send(column_name)
  end
end

module BasicAttributes
  extend ActiveSupport::Concern
  include CsvRowModel::AttributesBase
  attr_reader :source_row

  included do
    ensure_attribute_method
  end

  def initialize(*source_row)
    @source_row = source_row
  end

  def attribute_objects
    @attribute_objects ||= array_to_block_hash(self.class.column_names) { |column_name| BasicAttribute.new(column_name, self) }
  end

  class_methods do
    def define_attribute_method(column_name)
      super { source_row[self.class.columns.keys.index(column_name)] }
    end
  end
end

class BasicDynamicColumnAttribute < CsvRowModel::Model::DynamicColumnAttribute
  def unformatted_value
    formatted_cells
  end

  def source_cells
    row_model.header_models
  end
  def self.define_process_cell(*args); end
end

module BasicDynamicColumns
  extend ActiveSupport::Concern
  include BasicAttributes
  include CsvRowModel::DynamicColumnsBase

  included do
    ensure_define_dynamic_attribute_method
  end

  def dynamic_column_attribute_objects
    @dynamic_column_attribute_objects ||= array_to_block_hash(self.class.dynamic_column_names) do |column_name|
      self.class.dynamic_attribute_class.new(column_name, self)
    end
  end

  class_methods do
    def dynamic_attribute_class
      BasicDynamicColumnAttribute
    end
  end
end