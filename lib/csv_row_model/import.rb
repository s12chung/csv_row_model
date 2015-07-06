module CsvRowModel
  module Import
    extend ActiveSupport::Concern

    included do
      attr_reader :source_header, :source_row, :context, :previous

      # default methods for each column
      self.column_names.each.with_index do |column_name, column_index|
        self.send(:define_method, column_name) do
          self.class.format_cell mapped_row[column_name], column_name, column_index
        end
      end

      validates :source_row, presence: true
    end

    def initialize(source_row, options={})
      options = options.symbolize_keys.reverse_merge(context: {})
      @source_row, @context = source_row, OpenStruct.new(options[:context])
      @source_header, @previous = options[:source_header], options[:previous].try(:dup)

      previous.try(:free_previous)
      super(options)
    end

    def mapped_row
      return {} unless source_row
      @mapped_row ||= self.class.column_names.zip(source_row).to_h
    end

    # free previous from memory to avoid making a linked list
    def free_previous
      @previous = nil
    end

    class_methods do
      def has_many_relationships
        memoized_class_included_var :has_many_relationships, {}, Import
      end

      # May be overridden
      def format_cell(cell, column_name, column_index)
        cell
      end
    end
  end
end