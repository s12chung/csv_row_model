module CsvRowModel
  module Base
    extend ActiveSupport::Concern

    # TODO: more validations
    def skip?
      false
    end

    def abort?
      false
    end

    module ClassMethods
      def included_csv_model_base_class
        @included_csv_model_base_class ||= ancestors[ancestors.index(CsvRowModel::Base) - 1]
      end

      def column_names
        if self == included_csv_model_base_class
          @column_names ||= []
        else
          included_csv_model_base_class.column_names
        end
      end

      private
      def column(column_name)
        column_names << column_name
      end
    end
  end
end