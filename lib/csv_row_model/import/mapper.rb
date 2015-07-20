module CsvRowModel
  module Import
    # Represents a mapping between a {Import} {row_model} and your own models
    #
    # __Should implement the class method {row_model_class}__
    module Mapper
      extend ActiveSupport::Concern

      included do
        include ActiveWarnings
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
        class RowModelClassNotDefined < StandardError;end


        # @return [Class] returns the class that includes {Model} that the {Mapper} class maps to
        # defaults based on self.class: `FooMapper` or `Foo` => `FooRowModel` or the one set by {Mapper.maps_to}
        def row_model_class
          return @row_model_class if @row_model_class

          @row_model_class = "#{self.name.chomp("Mapper")}RowModel".safe_constantize
          return @row_model_class if @row_model_class

          raise RowModelClassNotDefined
        end

        protected

        # Sets the row model class that that the {Mapper} class maps to
        # @param [Class] row_model_class the class that includes {Model} that the {Mapper} class maps to
        def maps_to(row_model_class)
          if @row_model_class && @row_model_class != row_model_class
            Kernel.warn "CsvRowModel::Import::Mapper::maps_to changing row_model_class"\
                      " from #{@row_model_class} to #{row_model_class}"
          end
          @row_model_class = row_model_class
        end

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
      end
    end
  end
end
