module CsvRowModel
  # Include this to with {Model} to have a RowModel for exporting to CSVs.
  module Export
    extend ActiveSupport::Concern

    included do
      attr_reader :source_model, :context

      self.column_names.each do |column_name|

        # Safe to override
        #
        #
        # @return [String] a string of public_send(column_name) of the CSV model
        define_method(column_name) do
          source_model.public_send(column_name)
        end
      end

      validates :source_model, presence: true
    end

    # @param [Model] source_models object to export to CSV
    def initialize(source_model, context)
      @source_model = source_model
      @context = context
    end

    def to_rows
      [to_row]
    end

    # @return [Array] an array of public_send(column_name) of the CSV model
    def to_row
      attributes.values
    end

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


      # @return [Boolean] by default false
      def single_model?
        false
      end
    end

    private

    def is_column_name? column_name
      column_name.is_a?(Symbol) && self.class.index(column_name)
    end
  end
end
