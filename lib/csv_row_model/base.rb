module CsvRowModel
  module Base
    extend ActiveSupport::Concern

    included do
      include Columns
      include Children
    end

    # TODO: more validations
    def skip?
      false
    end

    def abort?
      false
    end

    module ClassMethods
      # the class that included this module, so we can store class instance variables there
      def included_csv_model_class
        @included_csv_model_class ||= begin
          inherited_ancestors = ancestors[0..(ancestors.index(Base) - 1)]
          index = inherited_ancestors.rindex {|inherited_ancestor| inherited_ancestor.class == Class }
          inherited_ancestors[index]
        end
      end
    end
  end
end