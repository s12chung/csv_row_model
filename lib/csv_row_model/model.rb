require 'csv_row_model/model/columns'
require 'csv_row_model/model/children'

module CsvRowModel
  module Model
    extend ActiveSupport::Concern

    included do
      include ActiveModel::Validations

      include Columns

      include Children
      attr_reader :parent
    end

    def initialize(options={})
      @parent = options[:parent]
    end

    # TODO: more validations
    def valid?
      return false if child? && !parent.valid?
      super
    end

    def skip?
      !valid?
    end

    def abort?
      false
    end

    module ClassMethods
      private

      def memoized_class_included_var(variable_name, default_value, included_module)
        class_included = class_included(included_module)
        if self == class_included
          #
          # equal to: @variable_name ||= default_value
          #
          variable_name = "@#{variable_name}"
          instance_variable_get(variable_name) || instance_variable_set(variable_name, default_value)
        else
          class_included.public_send(variable_name)
        end
      end

      # the class that included included_module, so we can store class instance variables there
      def class_included(included_module)
        @class_included ||= {}
        @class_included[included_module] ||= begin
          inherited_ancestors = ancestors[0..(ancestors.index(included_module) - 1)]
          index = inherited_ancestors.rindex {|inherited_ancestor| inherited_ancestor.class == Class }
          inherited_ancestors[index]
        end
      end
    end
  end
end