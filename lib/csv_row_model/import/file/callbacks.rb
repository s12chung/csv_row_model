module CsvRowModel
  module Import
    class File
      module Callbacks
        extend ActiveSupport::Concern

        included do
          extend ActiveModel::Callbacks

          define_model_callbacks :next

          define_model_callbacks :each
          define_model_callbacks :yield
          define_model_callbacks :abort, :skip, only: :before
        end
      end
    end
  end
end