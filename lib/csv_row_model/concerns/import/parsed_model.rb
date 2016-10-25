module CsvRowModel
  module Import
    module ParsedModel
      extend ActiveSupport::Concern

      def valid?(*args)
        super
        call_wrapper = using_warnings? ? parsed_model.method(:using_warnings) : ->(&block) { block.call }
        call_wrapper.call do
          parsed_model.valid?(*args)
          errors.messages.merge!(parsed_model.errors.messages.reject {|k, v| v.empty? })
          errors.empty?
        end
      end

      # @return [Import::ParsedModel::Model] a model with validations related to parsed_model (values are from format_cell)
      def parsed_model
        @parsed_model ||= begin
          attribute_objects = _attribute_objects
          formatted_hash = array_to_block_hash(self.class.column_names) { |column_name| attribute_objects[column_name].formatted_value }
          self.class.parsed_model_class.new(formatted_hash)
        end
      end

      protected
      def _original_attribute(column_name)
        parsed_model.valid?
        return nil unless parsed_model.errors[column_name].blank?
      end

      class_methods do
        # @return [Class] the Class with validations of the parsed_model
        def parsed_model_class
          @parsed_model_class ||= inherited_custom_class(:parsed_model_class, Model)
        end

        protected
        # Called to add validations to the parsed_model_class
        def parsed_model(&block)
          parsed_model_class.class_eval(&block)
        end
      end

      class Model < OpenStruct
        include ActiveWarnings

        class << self
          def valid_options
            %i[type validate_type]
          end

          def custom_check_options(options)
            return unless options[:validate_type]
            class_string = "#{options[:type].to_s.classify}FormatValidator"
            raise ArgumentError.new("with :validate_type and given :type of #{options[:type]}, the class #{class_string} must be defined") unless class_string.safe_constantize
          end

          # Adds the type validation based on :validate_type option
          def add_type_validation(column_name, options)
            return unless options[:validate_type]

            type = options[:type]
            class_eval { validates column_name, :"#{type.to_s.underscore}_format" => true, allow_blank: true }
          end
        end
      end
    end
  end
end