module CsvRowModel
  module Model
    module Children
      extend ActiveSupport::Concern

      def child?
        !!parent
      end

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

      def deep_public_send(method)
        result = [public_send(method)]
        result + self.class.has_many_relationships.keys.map do |relation_name|
          public_send(relation_name).map(&method)
        end.flatten(1)
      end

      module ClassMethods
        private
        # ::has_many_relationships is based off ::class_included(Input or Output)
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