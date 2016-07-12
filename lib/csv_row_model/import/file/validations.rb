module CsvRowModel
  module Import
    class File
      module Validations
        extend ActiveSupport::Concern

        include ActiveWarnings

        included do
          warnings do
            validate { errors.add(:csv, "has header with #{csv.headers.message}") unless csv.headers.class == Array }
          end
        end

        # @return [Boolean] returns true, if the file should abort reading
        def abort?
          !valid? || !!current_row_model.try(:abort?)
        end

        # @return [Boolean] returns true, if the file should skip `current_row_model`
        def skip?
          !!current_row_model.try(:skip?)
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