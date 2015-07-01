module CsvRowModel
  module Import
    extend ActiveSupport::Concern

    included do
      attr_reader :source_header, :soruce_row, :mapped_row, :context, :previous

      self.column_names.each do |column_name|
        self.send(:define_method, column_name) do
          mapped_row.public_send(column_name)
        end
      end
    end

    def initialize(source_row, context: {}, source_header: nil, previous: nil)
      @source_row, @context, @source_header, @previous = source_row, OpenStruct.new(context), source_header, previous.try(:dup)

      previous.try(:free_previous)

      @mapped_row = OpenStruct.new
      self.class.column_names.each.with_index do |column_name, index|
        @mapped_row.public_send("#{column_name}=", source_row[index])
      end
    end

    # free previous from memory to avoid making a linked list
    def free_previous
      @previous = nil
    end

    module ClassMethods
      # TODO: handle inheritance again
      def has_many(relation_name, relation_class)
        @relation_name, @relation_class = relation_name, relation_class
      end

      # TODO: handle children
      def child?(row)
        false
      end
    end
  end
end