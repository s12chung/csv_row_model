require 'csv_row_model/import/attributes'
require 'csv_row_model/import/presenter/concern'

module CsvRowModel
  # Include this to with {Model} to have a RowModel for importing csvs.
  module Import
    extend ActiveSupport::Concern

    included do
      include Concerns::Inspect
      include Attributes
      include Presenter::Concern

      attr_reader :attr_reader, :source_header, :source_row, :context, :index, :previous

      self.column_names.each { |*args| define_attribute_method(*args) }

      validates :source_row, presence: true
    end

    # @param [Array] source_row the csv row
    # @param options [Hash]
    # @option options [Integer] :index index in the CSV file
    # @option options [Hash] :context extra data you want to work with the model
    # @option options [Array] :source_header the csv header row
    # @option options [CsvRowModel::Import] :previous the previous row model
    # @option options [CsvRowModel::Import] :parent if the instance is a child, pass the parent
    def initialize(source_row, options={})
      options = options.symbolize_keys.reverse_merge(context: {})
      @source_row, @context = source_row, OpenStruct.new(options[:context])
      @index, @source_header, @previous = options[:index], options[:source_header], options[:previous].try(:dup)

      previous.try(:free_previous)
      super(source_row, options)
    end

    # @return [Hash] a map of `column_name => source_row[index_of_column_name]`
    def mapped_row
      return {} unless source_row
      @mapped_row ||= self.class.column_names.zip(source_row).to_h
    end


    # @return [Model::CsvStringModel] a model with validations related to Model::csv_string_model (values are from format_cell)
    def csv_string_model
      @csv_string_model ||= begin
        if source_row
          column_names = self.class.column_names
          hash = column_names.zip(column_names.map.with_index do |column_name, index|
                                    self.class.format_cell(source_row[index], column_name, index)
                                  end).to_h
        else
          hash = {}
        end
        self.class.csv_string_model_class.new(hash)
      end
    end

    def valid?(*args)
      super

      proc = -> do
        csv_string_model.valid?(*args)
        errors.messages.merge!(csv_string_model.errors.messages.reject {|k, v| v.empty? })
        errors.empty?
      end

      if using_warnings?
        csv_string_model.using_warnings &proc
      else
        proc.call
      end
    end

    # Free `previous` from memory to avoid making a linked list
    def free_previous
      @previous = nil
    end

    class_methods do
      INSPECT_INSTANCE_VARIABLES = %i[@mapped_row @initialized_at @parent @context @previous].freeze
      def inspect_instance_variables
        INSPECT_INSTANCE_VARIABLES
      end

      # by default import model is a collection model
      def type
        :collection_model
      end

      # See {Model#column}
      def column(column_name, options={})
        super
        define_attribute_method(column_name)
      end
    end
  end
end
