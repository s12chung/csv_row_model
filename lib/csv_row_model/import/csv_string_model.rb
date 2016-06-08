module CsvRowModel
  module Import
    module CsvStringModel
      extend ActiveSupport::Concern
      # Classes with a validations associated with them in csv_row_model/validators
      PARSE_VALIDATION_CLASSES = [Boolean, Integer, Float, Date, DateTime].freeze

      def valid?(*args)
        super
        call_wrapper = using_warnings? ? csv_string_model.method(:using_warnings) : ->(&block) { block.call }
        call_wrapper.call do
          csv_string_model.valid?(*args)
          errors.messages.merge!(csv_string_model.errors.messages.reject {|k, v| v.empty? })
          errors.empty?
        end
      end

      # @return [Import::CsvStringModel::Model] a model with validations related to csv_string_model (values are from format_cell)
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

      protected
      def _original_attribute(column_name)
        csv_string_model.valid?
        return nil unless csv_string_model.errors[column_name].blank?
      end

      class_methods do
        # @return [Class] the Class with validations of the csv_string_model
        def csv_string_model_class
          @csv_string_model_class ||= inherited_custom_class(:csv_string_model_class, Model)
        end

        protected
        # Called to add validations to the csv_string_model_class
        def csv_string_model(&block)
          csv_string_model_class.class_eval(&block)
        end

        # Adds the type validation based on :validate_type option
        def add_type_validation(column_name)
          options = options(column_name)
          validate_type = options[:validate_type]

          return unless validate_type

          type = options[:type]
          raise ArgumentError.new("invalid :type given for :validate_type for column") unless PARSE_VALIDATION_CLASSES.include? type

          csv_string_model { validates column_name, :"#{type.name.underscore}_format" => true, allow_blank: true }
        end
      end

      class Model < OpenStruct
        include ActiveWarnings
      end
    end
  end
end