module CsvRowModel
  module Base
    module Children
      extend ActiveSupport::Concern

      module ClassMethods
        def has_many_relationships
          self == included_csv_model_class ? (@has_many_relationships ||= {}) : included_csv_model_class.has_many_relationships
        end

        private

        def has_many(name, klass)
          raise "#{self}::has_many may only be called once" if has_many_relationships
          has_many_relationships.merge!(name.to_sym => klass)
        end
      end
    end
  end
end