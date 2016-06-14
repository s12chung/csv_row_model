require 'csv_row_model/import/representation'

module CsvRowModel
  module Import
    module Represents
      extend ActiveSupport::Concern

      included do
        inherited_class_hash :representations
      end

      def representations
        @representations ||= array_to_block_hash(self.class.representation_names) do |representation_name|
          Representation.new(representation_name, self.class.representations[representation_name], self)
        end
      end

      def representation_value(representation_name)
        representations[representation_name].try(:value)
      end

      def attributes
        super.merge!(representation_attributes)
      end

      def representation_attributes
        attributes_from_method_names(self.class.representation_names)
      end

      def valid?(*args)
        super
        filter_errors
        errors.empty?
      end

      protected

      # remove each dependent attribute from errors if it's representation dependencies are in the errors
      def filter_errors
        self.class.representation_names.each do |representation_name|
          next unless errors.messages.slice(*representations[representation_name].dependencies).present?
          errors.delete representation_name
        end
      end

      class_methods do
        # @return [Array<Symbol>] names of all representations
        def representation_names
          representations.keys
        end

        protected

        # Defines a representation for singular resources
        #
        # @param [Symbol] representation_name name of representation to add
        # @param [Proc] block to define the attribute
        # @param options [Hash]
        # @option options [Hash] :memoize whether to memoize the attribute (default: true)
        # @option options [Hash] :dependencies the dependencies with other attributes/representations (default: [])
        def represents_one(*args, &block)
          define_representation_method(*args, &block)
        end

        # Defines a representation for multiple resources
        #
        # @param [Symbol] representation_name name of representation to add
        # @param [Proc] block to define the attribute
        # @param options [Hash]
        # @option options [Hash] :memoize whether to memoize the attribute (default: true)
        # @option options [Hash] :dependencies the dependencies with other attributes/representations (default: [])
        def represents_many(representation_name, options={}, &block)
          define_representation_method(representation_name, options.merge(empty_value: []), &block)
        end

        def define_representation_method(representation_name, options={}, &block)
          Representation.check_options(options)
          merge_representations(representation_name.to_sym => options)
          define_method(representation_name) { representation_value(representation_name) }
          Representation.define_lambda_method(self, representation_name, &block)
        end
      end
    end
  end
end