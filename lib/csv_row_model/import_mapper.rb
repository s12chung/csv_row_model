module CsvRowModel
  module ImportMapper
    extend ActiveSupport::Concern

    included do
      attr_reader :row_model

      delegate :context, :previous, :free_previous, to: :row_model
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
      def row_model_class
        raise NotImplementedError
      end
    end
  end
end