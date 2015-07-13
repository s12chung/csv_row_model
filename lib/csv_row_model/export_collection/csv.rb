module CsvRowModel
  module ExportCollection
    class Csv
      attr_reader :export_model_class, :enumerable

      # @param [Export] export_model export model class
      def initialize(export_model_class, enumerable)
        @export_model_class = export_model_class
        @enumerable = enumerable
      end

      def header
        export_model_class.column_headers
      end

      def export(without_header: false, enum_method: :each)
        CSV.generate do |csv|
          csv << header unless without_header
          enumerable.public_send(enum_method) do |model|
            csv << export_model_class.new(model).to_row
          end
        end
      end
    end
  end
end