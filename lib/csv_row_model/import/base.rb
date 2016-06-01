module CsvRowModel
  module Import
    module Base
      extend ActiveSupport::Concern

      included do
        attr_reader :source_header, :source_row, :context, :line_number, :index, :previous

        # need to simplify children code
        validate { errors.add(:source_row, "can't be nil") if source_row.nil? }
      end

      # @param [Array] source_row the csv row
      # @param options [Hash]
      # @option options [Integer] :index 1st row_model is 0, 2nd is 1, 3rd is 2, etc.
      # @option options [Integer] :line_number line_number in the CSV file
      # @option options [Hash] :context extra data you want to work with the model
      # @option options [Array] :source_header the csv header row
      # @option options [CsvRowModel::Import] :previous the previous row model
      # @option options [CsvRowModel::Import] :parent if the instance is a child, pass the parent
      def initialize(source_row=[], options={})
        options = options.symbolize_keys.reverse_merge(context: {})
        @source_row, @context = source_row, OpenStruct.new(options[:context])
        @line_number, @index, @source_header, @previous = options[:line_number], options[:index], options[:source_header], options[:previous].try(:dup)

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

      # @return [Model::CsvStringModel] a model with validations related to Model::csv_string_model (values are from format_cell)
      def csv_string_model
        @csv_string_model ||= begin
          if source_row
            column_names = self.class.column_names
            hash = column_names.zip(
              column_names.map.with_index do |column_name, index|
                self.class.format_cell(source_row[index], column_name, index, context)
              end
            ).to_h
          else
            hash = {}
          end

          self.class.csv_string_model_class.new(hash)
        end
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

      def valid?(*args)
        super

        proc = -> do
          csv_string_model.valid?(*args)
          errors.messages.merge!(csv_string_model.errors.messages.reject {|k, v| v.empty? })
          errors.empty?
        end

        if using_warnings?
          csv_string_model.using_warnings(&proc)
        else
          proc.call
        end
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

        #
        # Call to define the Presenter (do nothing, will remove)
        #
        def presenter; end
      end
    end
  end
end
