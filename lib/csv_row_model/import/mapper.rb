module CsvRowModel
  module Import
    # Represents a mapping between a import row model and your own models
    module Mapper
      extend ActiveSupport::Concern

      included do
        include ActiveModel::Validations
        include Validators::ValidateAttributes

        attr_reader :row_model

        delegate :context, :previous, :free_previous, :append_child,
                 :attributes, :to_json, to: :row_model

        validates :row_model, presence: true
        validate_attributes :row_model
      end

      def initialize(*args)
        @row_model = self.class.row_model_class.new(*args)
      end

      # Safe to override.
      #
      # @return [Boolean] returns true, if this instance should be skipped
      def skip?
        !valid? || row_model.skip?
      end

      # Safe to override.
      #
      # @return [Boolean] returns true, if the entire csv file should stop reading
      def abort?
        row_model.abort?
      end

      class_methods do
        protected

        # For every method name define the following:
        #
        # ```ruby
        # def method_name; @method_name ||= _method_name end
        # ```
        #
        # @param [Array<Symbol>] method_names method names to memoize
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