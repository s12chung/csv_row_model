require 'csv_row_model/import/presenter'

module CsvRowModel
  module Import
    class Presenter
      # Included to {Import}
      module Concern
        extend ActiveSupport::Concern

        # @return [Presenter] the presenter of self
        def presenter
          @presenter ||= self.class.presenter_class.new(self)
        end

        protected

        class_methods do
          # @return [Class] the Class of the Presenter
          def presenter_class
            @presenter_class ||= inherited_custom_class(:presenter_class, Presenter)
          end

          protected
          # Call to define the presenter
          def presenter
            presenter_class.instance_eval &block
          end
        end
      end
    end
  end
end