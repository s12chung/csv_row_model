module CsvRowModel
  module Model
    module Children
      extend ActiveSupport::Concern

      # @returns [Boolean] returns true, if the instance is a child
      def child?
        !!parent
      end

      # Appends child to the parent and returns it
      #
      # @returns [Model] return the child if it is valid, otherwise returns nil
      def append_child(source, options={})
        self.class.has_many_relationships.each do |relation_name, child_class|
          child_row_model = child_class.new(source, options.reverse_merge(parent: self))
          if child_row_model.valid?
            public_send(relation_name) << child_row_model
            return child_row_model
          end
        end
        nil
      end

      # Convenience method to return an array of calling `public_send(method_name)` on itself and it's children
      #
      # @returns [Array] results of `public_send(method_name)` in a flattened array
      def deep_public_send(method_name)
        result = [public_send(method_name)]
        result + self.class.has_many_relationships.keys.map do |relation_name|
          public_send(relation_name).map(&method_name)
        end.flatten(1)
      end

      class_methods do
        protected
        # Defines a relationship between a row model (only one relation per model for now).
        #
        # @param [Symbol] relation_name the name of the relation
        # @param [CsvRowModel::Import] row_model_class class of the relation
        def has_many(relation_name, row_model_class)
          raise "for now, CsvRowModel's has_many may only be called once" if has_many_relationships.keys.present?

          relation_name = relation_name.to_sym
          has_many_relationships.merge!(relation_name => row_model_class)

          define_method(relation_name) do
            #
            # equal to: @relation_name ||= []
            #
            variable_name = "@#{relation_name}"
            instance_variable_get(variable_name) || instance_variable_set(variable_name, [])
          end
        end
      end
    end
  end
end