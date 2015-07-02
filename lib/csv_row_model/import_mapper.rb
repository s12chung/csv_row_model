module CsvRowModel
  module ImportMapper
    extend ActiveSupport::Concern

    included do
      attr_reader :row_model

      delegate :context, :previous, :free_previous, :append_child, to: :row_model
    end

    def initialize(*args)
      @row_model = self.class.row_model_class.new(*args)
    end

    # TODO: validations...
    def skip?
      row_model.skip?
    end

    def abort?
      row_model.abort?
    end

    module ClassMethods
      def memoize(*method_names)
        method_names.each do |method_name|
          define_method(method_name) do
            #
            # equal to: @method_name ||= _method_name
            #
            variable_name = "@#{method_name}"
            instance_variable_get(variable_name) || instance_variable_set(variable_name, send("_#{method_name}"))
          end
        end
      end

      def row_model_class
        raise NotImplementedError
      end
    end
  end
end