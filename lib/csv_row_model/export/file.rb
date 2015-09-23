module CsvRowModel
  module Export
    class File
      attr_reader :export_model_class, :csv, :file, :context

      # @param [Export] export_model export model class
      def initialize(export_model_class, context={})
        @export_model_class = export_model_class
        @context = context.to_h
      end

      def headers
        export_model_class.headers
      end

      # Add a row_model to the
      # @param [] source_model the source model of the export row model
      # @param [Hash] context the extra context given to the instance of the row model
      def append_model(source_model, context={})
        export_model_class.new(source_model, context.to_h.reverse_merge(self.context)).to_rows.each do |row|
          csv << row
        end
      end
      alias_method :<<, :append_model

      # @return [Boolean] true, if a csv file is generated
      def generated?
        !!file
      end

      # Open a block to generate a file
      # @param [Boolean] with_headers adds the header to the file if true
      def generate(with_headers: true)
        @file = Tempfile.new("#{export_model_class}.csv")
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
