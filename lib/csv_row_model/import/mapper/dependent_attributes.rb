module CsvRowModel
  module Import
    module Mapper
      module DependentAttributes
        extend ActiveSupport::Concern

        protected

        # add errors from row_model and remove each dependent attribute from errors if it's row_model_dependencies
        # are in the errors
        def filter_errors
          with_warnings? ? row_model.with_warnings { _filter_errors } : _filter_errors
        end

        def _filter_errors
          row_model.valid?
          self.class._dependent_attributes.each do |dependent_attribute_name, row_model_dependencies|
            next unless errors[dependent_attribute_name] && row_model.errors.messages.slice(*row_model_dependencies).present?
            errors.delete dependent_attribute_name
          end

          errors.messages.reverse_merge!(row_model.errors.messages)
        end

        # @param [Symbol] dependent_attribute_name the attribute to check
        # @return [Boolean] if the dependencies are valid
        def valid_dependencies?(dependent_attribute_name)
          row_model.valid? || (row_model.errors.keys & self.class._dependent_attributes[dependent_attribute_name]).empty?
        end

        # equal to: @method_name ||= _method_name
        # @param [Symbol] method_name method_name in description
        # @return [Object] the memoized result
        def memoize(method_name)
          variable_name = "@#{method_name}"
          instance_variable_get(variable_name) || instance_variable_set(variable_name, send("_#{method_name}"))
        end

        class_methods do
          # @return [Hash] a map of dependent_attribute_name => row_model_dependencies
          def _dependent_attributes
            @dependent_attributes ||= {}
          end

          protected
          # adds dependent_attributes
          # @param [Hash{Symbol => Array<Symbol>}] dependent_attributes a map of
          # dependent_attribute_name => row_model_dependencies
          def dependent_attributes(dependent_attributes)
            dependent_attributes = dependent_attributes.symbolize_keys
            dependent_attributes.each {|key, value| dependent_attributes[key] = value.map(&:to_sym)}

            _dependent_attributes.merge! dependent_attributes
            dependent_attributes.keys.each do |dependent_attribute_name|
              define_dependent_attribute(dependent_attribute_name)
            end
          end

          def define_dependent_attribute(attribute_name)
            define_method(attribute_name) do
              return unless valid_dependencies?(attribute_name)
              memoize(attribute_name)
            end
          end
        end
      end
    end
  end
end