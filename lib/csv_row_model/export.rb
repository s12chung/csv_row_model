module CsvRowModel
  # Include this to with {Model} to have a RowModel for exporting to CSVs.
  module Export
    extend ActiveSupport::Concern

    included do
      attr_reader :source_model

      self.column_names.each do |column_name|
        define_method(column_name) do
          source_model.public_send(column_name)
        end
      end

      validates :source_model, presence: true
    end

    # @param [Model] source_models object to export to CSV
    def initialize(source_model)
      @source_model = source_model
    end

    # @return [Array] an array of public_send(column_name) of the CSV model
    def to_row
      attributes.values
    end

    # to be tested when tests are up:
    # def raw_csv_model
    #   self.class.raw_csv_model_class.new(attributes)
    # end

    class_methods do

      # @return [Array] column headers for the row model
      def column_headers
        @column_headers ||= begin
          columns.map do |name, options|
            options[:header] || format_header(name)
          end
        end
      end

      # Safe to override
      #
      # @return [String] formatted header
      def format_header(column_name)
        column_name
      end

      # @param [Symbol] column_name name of column to find option
      # @return [Hash] options for the column_name
      def options(column_name)
        columns[column_name]
      end
    end
  end
end