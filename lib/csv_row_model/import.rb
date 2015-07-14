module CsvRowModel
  # Include this to with {Model} to have a RowModel for importing csvs.
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

    # @param [Array] source_row the csv row
    # @param options [Hash]
    # @option options [Hash] :context extra data you want to work with the model
    # @option options [Array] :source_header the csv header row
    # @option options [CsvRowModel::Import] :previous the previous row model
    # @option options [CsvRowModel::Import] :parent if the instance is a child, pass the parent
    def initialize(source_row, options={})
      options = options.symbolize_keys.reverse_merge(context: {})
      @source_row, @context = source_row, OpenStruct.new(options[:context])
      @source_header, @previous = options[:source_header], options[:previous].try(:dup)

      previous.try(:free_previous)
      super(source_row, options)
    end

    # @return [Hash] a map of `column_name => source_row[index_of_column_name]`
    def mapped_row
      return {} unless source_row
      @mapped_row ||= self.class.column_names.zip(source_row).to_h
    end

    # Free `previous` from memory to avoid making a linked list
    def free_previous
      @previous = nil
    end

    class_methods do

      # @return [Hash] map of `relation_name => CsvRowModel::Import class`
      def has_many_relationships
        memoized_class_included_var :has_many_relationships, {}, Import
      end

      # Safe to override. Method applied to each cell by default
      #
      # @param cell [String] the cell's string
      # @param column_name [Symbol] the cell's column_name
      # @param column_index [Integer] the column_name's index
      def format_cell(cell, column_name, column_index)
        cell
      end
    end
  end
end