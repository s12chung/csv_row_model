module CsvRowModel
  module Import
    module Represents
      extend ActiveSupport::Concern

      included do
        inherited_class_hash :representations
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
          next unless errors.messages[representation_name] &&
            errors.messages.slice(*self.class.representations[representation_name][:dependencies]).present?
          errors.delete representation_name
        end
      end

      # @param [Array] attribute_names of attribute_names to check
      # @return [Boolean] if attributes are present
      def attributes_present?(*attribute_names)
        attribute_names.each { |attribute_name| return false if public_send(attribute_name).blank? }
        true
      end

      # @param [Symbol] representation_name the representation to check
      # @return [Boolean] if the dependencies are valid
      def valid_dependencies?(representation_name)
        attributes_present?(*self.class.representations[representation_name][:dependencies])
      end


      # equal to: @method_name ||= yield
      # @param [Symbol] method_name method_name in description
      # @return [Object] the memoized result
      def memoize(method_name)
        variable_name = :"@#{method_name}"
        instance_variable_get(variable_name) || instance_variable_set(variable_name, yield)
      end

      class_methods do
        # @return [Array<Symbol>] names of all representations
        def representation_names
          representations.keys
        end

        # Defines a representation for singular resources
        #
        # @param [Symbol] representation_name name of representation to add
        # @param [Proc] block to define the attribute
        # @param options [Hash]
        # @option options [Hash] :memoize whether to memoize the attribute (default: true)
        # @option options [Hash] :dependencies the dependencies with other attributes/representations (default: [])
        def represents_one(representation_name, options={}, &block)
          set_representation_options representation_name, options
          define_representation_method(representation_name, &block)
        end

        # Defines a representation for multiple resources
        #
        # @param [Symbol] representation_name name of representation to add
        # @param [Proc] block to define the attribute
        # @param options [Hash]
        # @option options [Hash] :memoize whether to memoize the attribute (default: true)
        # @option options [Hash] :dependencies the dependencies with other attributes/representations (default: [])
        def represents_many(representation_name, options={}, &block)
          set_representation_options representation_name, options
          define_representation_method(representation_name, [], &block)
        end

        protected
        def set_representation_options(presentation_name, options={})
          options = check_and_merge_options(options, memoize: true, dependencies: [])
          merge_representations(presentation_name.to_sym => options)
        end

        # Define the representation_method
        # @param [Symbol] representation_name name of representation to add
        def define_representation_method(representation_name, empty_value=nil, &block)
          define_method(:"__#{representation_name}", &block)

          define_method(representation_name) do
            return empty_value unless valid_dependencies?(representation_name)
            self.class.representations[representation_name][:memoize] ?
              memoize(representation_name) { public_send(:"__#{representation_name}") } :
              public_send(:"__#{representation_name}")
          end
        end
      end
    end
  end
end