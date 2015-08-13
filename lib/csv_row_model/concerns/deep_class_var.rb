module CsvRowModel
  module Concerns
    module DeepClassVar
      extend ActiveSupport::Concern

      class_methods do
        protected

        # @return [Array<Module>] inherited_ancestors of deep_class_module (including self)
        def inherited_ancestors
          ancestors[0..(ancestors.index(deep_class_module) - 1)]
        end

        # @param variable_name [Symbol] class variable name (recommend :@_variable_name)
        # @param default_value [Object] default value of the class variable
        # @param merge_method [Symbol] method to merge values of the class variable
        # @return [Object] a class variable merged across ancestors until deep_class_module
        def deep_class_var(variable_name, default_value, merge_method)
          value = default_value

          inherited_ancestors.each do |ancestor|
            ancestor_value = ancestor.instance_variable_get(variable_name)
            value = ancestor_value.public_send(merge_method, value) if ancestor_value.present?
          end

          value
        end
      end
    end
  end
end