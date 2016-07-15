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