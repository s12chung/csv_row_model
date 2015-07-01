module CsvRowModel
  module Import
    extend ActiveSupport::Concern

    included do
      attr_reader :source_header, :source_row, :mapped_row, :context, :previous

      self.column_names.each.with_index do |column_name, column_index|
        self.send(:define_method, column_name) do
          self.class.format_cell mapped_row.public_send(column_name), column_name, column_index
        end
      end
    end

    def initialize(source_row, context: {}, source_header: nil, previous: nil)
      @source_row, @context, @source_header, @previous = source_row, OpenStruct.new(context), source_header, previous.try(:dup)

      previous.try(:free_previous)

      @mapped_row = OpenStruct.new
      self.class.column_names.each.with_index do |column_name, column_index|
        @mapped_row.public_send("#{column_name}=", source_row[column_index])
      end
    end

    # free previous from memory to avoid making a linked list
    def free_previous
      @previous = nil
    end

    module ClassMethods
      # TODO: handle children
      def child?(row)
        false
      end

      # May be overridden
      def format_cell(cell, column_name, column_index)
        cell
      end

      private
      # TODO: handle inheritance again
      def has_many(relation_name, relation_class)
        @relation_name, @relation_class = relation_name, relation_class
      end
    end
  end
end