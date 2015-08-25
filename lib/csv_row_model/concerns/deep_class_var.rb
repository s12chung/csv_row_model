module CsvRowModel
  module Concerns
    module DeepClassVar
      extend ActiveSupport::Concern

      class_methods do
        # Clears the cache for a variable
        # @param variable_name [Symbol] variable_name to cache against
        def clear_class_cache(variable_name)
          instance_variable_set deep_class_cache_variable_name(variable_name), nil
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
          deep_class_cache(variable_name) do
            value = default_value

            inherited_ancestors.each do |ancestor|
              ancestor_value = ancestor.instance_variable_get(variable_name)
              value = ancestor_value.public_send(merge_method, value) if ancestor_value.present?
            end

            value
          end
        end

        # @param variable_name [Symbol] variable_name to cache against
        # @return [String] the cache variable name for the cache
        def deep_class_cache_variable_name(variable_name)
          "#{variable_name}_deep_class_cache"
        end

        # Clears the cache for a variable and the same variable for all it's dependant descendants
        # @param variable_name [Symbol] variable_name to cache against
        def clear_deep_class_cache(variable_name)
          ([self] + descendants).each do |descendant|
            descendant.try(:clear_class_cache, variable_name)
          end
        end

        # Memozies a deep_class_cache_variable_name
        # @param variable_name [Symbol] variable_name to cache against
        def deep_class_cache(variable_name)
          #
          # equal to: (has @)variable_name_deep_class_cache ||= Cache.new(klass, variable_name)
          #
          cache_variable_name = deep_class_cache_variable_name(variable_name)
          instance_variable_get(cache_variable_name) || instance_variable_set(cache_variable_name, yield)
        end
      end
    end
  end
end