module CsvRowModel
  module Concerns
    module InheritedClassVar
      extend ActiveSupport::Concern

      class_methods do
        # Clears the cache for a variable
        # @param variable_name [Symbol] variable_name to cache against
        def clear_class_cache(variable_name)
          instance_variable_set inherited_class_variable_name(variable_name), nil
        end

        protected

        # @param variable_name [Symbol] class variable name
        def inherited_class_hash(variable_name)
          hidden_variable_name = hidden_variable_name(variable_name)

          define_singleton_method variable_name do
            inherited_class_var(hidden_variable_name, {}, :merge)
          end

          define_singleton_method "merge_#{variable_name}" do |merge_value|
            value = instance_variable_get(hidden_variable_name) || instance_variable_set(hidden_variable_name, {})
            deep_clear_class_cache(hidden_variable_name)
            value.merge!(merge_value)
          end
        end

        def hidden_variable_name(variable_name)
          "@_#{variable_name}".to_sym
        end

        # @param included_module [Module] module to search for
        # @return [Array<Module>] inherited_ancestors of included_module (including self)
        def inherited_ancestors(included_module=inherited_class_module)
          included_model_index = ancestors.index(included_module)
          included_model_index == 0 ? [included_module] : ancestors[0..(included_model_index - 1)]
        end

        # @param accessor_method_name [Symbol] method to access the inherited_custom_class
        # @param base_parent_class [Class] class that the custom class inherits from if there's no parent
        # @return [Class] a custom class with the inheritance following self. for example:
        #
        # grandparent -> parent -> self
        #
        # grandparent has inherited_custom_class, but parent, doesn't.
        #
        # then: base_parent_class -> grandparent::inherited_custom_class -> self::inherited_custom_class
        def inherited_custom_class(accessor_method_name, base_parent_class)
          parent_class = inherited_ancestors[1..-1].find do |klass|
            klass.respond_to?(accessor_method_name)
          end.try(accessor_method_name)
          parent_class ||= base_parent_class

          klass = Class.new(parent_class)
          # how else can i get the current scopes name...
          klass.send(:define_singleton_method, :name, &eval("-> { \"#{name}#{base_parent_class.name.demodulize}\" }"))
          klass
        end

        # @param variable_name [Symbol] class variable name (recommend :@_variable_name)
        # @param default_value [Object] default value of the class variable
        # @param merge_method [Symbol] method to merge values of the class variable
        # @return [Object] a class variable merged across ancestors until inherited_class_module
        def inherited_class_var(variable_name, default_value, merge_method)
          class_cache(variable_name) do
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
        def inherited_class_variable_name(variable_name)
          "#{variable_name}_inherited_class_cache"
        end

        # Clears the cache for a variable and the same variable for all it's dependant descendants
        # @param variable_name [Symbol] variable_name to cache against
        def deep_clear_class_cache(variable_name)
          ([self] + descendants).each do |descendant|
            descendant.try(:clear_class_cache, variable_name)
          end
        end

        # Memozies a inherited_class_variable_name
        # @param variable_name [Symbol] variable_name to cache against
        def class_cache(variable_name)
          #
          # equal to: (has @)inherited_class_variable_name ||= yield
          #
          cache_variable_name = inherited_class_variable_name(variable_name)
          instance_variable_get(cache_variable_name) || instance_variable_set(cache_variable_name, yield)
        end
      end
    end
  end
end