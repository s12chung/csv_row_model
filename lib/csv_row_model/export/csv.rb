require 'csv'

module CsvRowModel
  module Export
    class Csv
      attr_reader :export_model_class, :csv, :file

      # @param [Export] export_model export model class
      def initialize(export_model_class)
        @export_model_class = export_model_class
        @file = Tempfile.new("#{export_model_class}.csv")
      end

      def header
        export_model_class.column_headers
      end

      def append_model(model, context={})
        export_model_class.new(model, context).to_rows.each do |row|
          csv << row
        end
      end

      def generate(with_header: true)
        CSV.open(file.path,"wb") do |csv|
          @csv = csv
          export_model_class.setup(csv, with_header: with_header)
          yield self
        end
      ensure
        @csv = nil
      end

      def to_s
        file.read
      end
    end
  end
end
