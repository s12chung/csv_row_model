module CsvRowModel
  module Import
    module Base
      extend ActiveSupport::Concern

      included do
        attr_reader :source_header, :source_row, :line_number, :index, :previous

        validate { errors.add(:csv, "has #{@csv_exception.message}") if @csv_exception }
      end

      # @param [Array] source_row_or_exception the csv row
      # @param options [Hash]
      # @option options [Integer] :index 1st row_model is 0, 2nd is 1, 3rd is 2, etc.
      # @option options [Integer] :line_number line_number in the CSV file
      # @option options [Array] :source_header the csv header row
      # @option options [CsvRowModel::Import] :previous the previous row model
      # @option options [CsvRowModel::Import] :parent if the instance is a child, pass the parent
      def initialize(source_row_or_exception=[], options={})
        @source_row = source_row_or_exception
        @csv_exception = source_row if source_row.kind_of? Exception
        @source_row = [] if source_row_or_exception.class != Array

        @line_number, @index, @source_header = options[:line_number], options[:index], options[:source_header]

        @previous = options[:previous].try(:dup)
        previous.try(:free_previous)
        super(options)
      end

      # @return [Hash] a map of `column_name => source_row[index_of_column_name]`
      def mapped_row
        return {} unless source_row
        @mapped_row ||= self.class.column_names.zip(source_row).to_h
      end

      # Free `previous` from memory to avoid making a linked list
      def free_previous
        attributes
        @previous = nil
      end

      # Safe to override.
      #
      # @return [Boolean] returns true, if this instance should be skipped
      def skip?
        !valid?
      end

      # Safe to override.
      #
      # @return [Boolean] returns true, if the entire csv file should stop reading
      def abort?
        false
      end

      class_methods do
        #
        # Move to Import::File once FileModel is removed.
        #
        # @param [Import::File] file to read from
        # @param [Hash] context extra data you want to work with the model
        # @param [Import] prevuous the previous row model
        # @return [Import] the next model instance from the csv
        def next(file, context={})
          csv = file.csv
          csv.skip_header
          row_model = nil

          loop do # loop until the next parent or end_of_file? (need to read children rows)
            csv.read_row
            row_model ||= new(csv.current_row,
                              line_number: csv.line_number,
                              index: file.index,
                              source_header: csv.header,
                              context: context,
                              previous: file.previous_row_model)

            return row_model if csv.end_of_file?

            next_row_is_parent = !row_model.append_child(csv.next_row)
            return row_model if next_row_is_parent
          end
        end

        protected
        def inspect_methods
          @inspect_methods ||= %i[mapped_row initialized_at parent context previous].freeze
        end
      end
    end
  end
end
