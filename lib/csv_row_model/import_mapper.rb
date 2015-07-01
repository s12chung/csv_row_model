module CsvRowModel
  module ImportMapper
    extend ActiveSupport::Concern

    included do
      attr_reader :row_model

      delegate :context, :previous, :free_previous, :abort?, :skip?, to: :row_model
    end

    def initialize(*args)
      @row_model = self.class.row_model_class.new(*args)
    end
  end
end