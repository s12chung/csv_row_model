module CsvRowModel
  module Import
    module Mapper
      extend ActiveSupport::Concern

      included do
        include ActiveModel::Validations
        include Validators::ValidateVariables

        attr_reader :row_model

        delegate :context, :previous, :free_previous, :append_child,
                 :skip?, :abort?, :attributes, :to_json, to: :row_model

        validates :row_model, presence: true
        validate_variables :row_model
      end

      def initialize(*args)
        @row_model = self.class.row_model_class.new(*args)
      end

      module ClassMethods
        def memoize(*method_names)
          method_names.each do |method_name|
            define_method(method_name) do
              #
              # equal to: @method_name ||= _method_name
              #
              variable_name = "@#{method_name}"
              instance_variable_get(variable_name) || instance_variable_set(variable_name, send("_#{method_name}"))
            end
          end
        end

        def row_model_class
          raise NotImplementedError
        end
      end
    end
  end
end