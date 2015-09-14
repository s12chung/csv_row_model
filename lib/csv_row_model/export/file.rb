module CsvRowModel
  module Export
    class File
      attr_reader :export_model_class, :csv, :file, :context

      # @param [Export] export_model export model class
      def initialize(export_model_class, context={})
        @export_model_class = export_model_class
        @file = Tempfile.new("#{export_model_class}.csv")
        @context = context
      end

      def headers
        export_model_class.headers
      end

      def append_model(model)
        export_model_class.new(model, context).to_rows.each do |row|
          csv << row
        end
      end
      alias_method :<<, :append_model

      def generate(with_headers: true)
        CSV.open(file.path,"wb") do |csv|
          @csv = csv
          export_model_class.setup(csv, with_headers: with_headers)
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
