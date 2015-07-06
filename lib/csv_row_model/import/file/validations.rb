module CsvRowModel
  module Import
    class File
      module Validations
        extend ActiveSupport::Concern

        included do
          include ActiveModel::Validations
        end

        def abort?
          !valid? || current_row_model.try(:abort?)
        end

        def skip?
          current_row_model.try(:skip?)
        end

        # TODO: check valid file or abort
        def valid?
          super
        end

        protected
        def _abort?
          abort = abort?
          run_callbacks(:abort) if abort
          abort
        end

        def _skip?
          skip = skip?
          run_callbacks(:skip) if skip
          skip
        end
      end
    end
  end
end