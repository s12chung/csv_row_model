require 'csv_row_model/concerns/deep_class_var/cache'

module CsvRowModel
  module Concerns
    module DeepClassVar
      extend ActiveSupport::Concern

      class_methods do
        def break_cache(variable_name)
          cache(variable_name).break
        end

        protected

        # @param included_module [Module] module to search for
        # @return [Array<Module>] inherited_ancestors of included_module (including self)
        def inherited_ancestors(included_module=deep_class_module)
          included_model_index = ancestors.index(included_module)
          included_model_index == 0 ? [included_module] : ancestors[0..(included_model_index - 1)]
        end

        # @param variable_name [Symbol] class variable name (recommend :@_variable_name)
        # @param default_value [Object] default value of the class variable
        # @param merge_method [Symbol] method to merge values of the class variable
        # @return [Object] a class variable merged across ancestors until deep_class_module
        def deep_class_var(variable_name, default_value, merge_method)
          cache(variable_name).cache do
            value = default_value

            inherited_ancestors.each do |ancestor|
              ancestor_value = ancestor.instance_variable_get(variable_name)
              value = ancestor_value.public_send(merge_method, value) if ancestor_value.present?
            end

            value
          end
        end

        def cache(variable_name)
          #
          # equal to: (has @)variable_name_deep_class_cache ||= Cache.new(klass, variable_name)
          #
          cache_variable_name = "#{variable_name}_deep_class_cache"
          instance_variable_get(cache_variable_name) || instance_variable_set(cache_variable_name, Cache.new(self, variable_name))
        end
      end
    end
  end
end