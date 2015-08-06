require 'csv_row_model/model/csv_string_model'

module CsvRowModel
  module Model
    module Validations
      extend ActiveSupport::Concern

      included do
        include Concerns::DeepClassVar

        include ActiveWarnings
        include Validators::ValidateAttributes

        class << self
          # @return [Class] the Class with validations of the csv_string_model
          def csv_string_model_class
            @csv_string_model_class ||= begin
              parent_class = inherited_ancestors(Validations)[1..-1].find do |klass|
                klass.respond_to?(:csv_string_model_class)
              end.try(:csv_string_model_class)
              parent_class ||= CsvStringModel

              klass = Class.new(parent_class)
              # how else can i get the current scopes name...
              klass.send(:define_singleton_method, :name, &eval("-> { \"#{name}CsvStringModel\" }"))
              klass
            end
          end

          protected
          # Called to add validations to the csv_string_model_class
          def csv_string_model(&block)
            csv_string_model_class.instance_eval &block
          end
        end
      end
    end
  end
end