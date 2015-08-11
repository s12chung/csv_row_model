module CsvRowModel
  module Concerns
    module DeepClassVar
      extend ActiveSupport::Concern

      class_methods do
        protected

        # @param included_module [Module] module to search for
        # @return [Array<Module>] inherited_ancestors of included_module (including self)
        def inherited_ancestors(included_module)
          ancestors[0..(ancestors.index(included_module) - 1)]
        end

        # @param variable_name [Symbol] class variable name (recommend :@_variable_name)
        # @param default_value [Object] default value of the class variable
        # @param merge_method [Symbol] method to merge values of the class variable
        # @param included_module [Module] module to search for
        # @return [Object] a class variable merged across ancestors until included_module
        def deep_class_var(variable_name, default_value, merge_method, included_module)
          value = default_value

          inherited_ancestors(included_module).each do |ancestor|
            ancestor_value = ancestor.instance_variable_get(variable_name)
            value = ancestor_value.public_send(merge_method, value) if ancestor_value.present?
          end

          value
        end
      end
    end
  end
end