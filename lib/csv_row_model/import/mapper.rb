require 'csv_row_model/import/mapper/attributes'

module CsvRowModel
  module Import
    # Represents a mapping between a {Import} {row_model} and your own models
    module Mapper
      extend ActiveSupport::Concern

      included do
        include ActiveWarnings
        include Validators::ValidateAttributes
        include Attributes

        attr_reader :row_model

        def valid?(*args)
          super
          filter_errors
          errors.empty?
        end
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

      protected

      # allow Mapper to delegate missing methods to the row_model, EXCEPT column_name methods to keep separation
      def method_missing(name, *args, &block)
        super
      rescue NoMethodError, NameError => original_error
        raise original_error if row_model.class.column_names.include? name

        begin
          row_model.public_send name, *args, &block
        rescue NoMethodError, NameError => new_error
          if new_error.name == name && new_error.args == args
            raise original_error
          else
            raise new_error
          end
        end
      end

      class_methods do
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
      end
    end
  end
end
