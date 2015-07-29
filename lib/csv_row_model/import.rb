module CsvRowModel
  # Include this to with {Model} to have a RowModel for importing csvs.
  module Import
    extend ActiveSupport::Concern

    included do
      attr_reader :attr_reader, :source_header, :source_row, :context, :previous

      self.column_names.each { |*args| define_attribute_method(*args) }

      validates :source_row, presence: true
    end

    # @param [Array] source_row the csv row
    # @param options [Hash]
    # @option options [Hash] :context extra data you want to work with the model
    # @option options [Array] :source_header the csv header row
    # @option options [CsvRowModel::Import] :previous the previous row model
    # @option options [CsvRowModel::Import] :parent if the instance is a child, pass the parent
    def initialize(source_row, options={})
      options = options.symbolize_keys.reverse_merge(context: {})
      @source_row, @context = source_row, OpenStruct.new(options[:context])
      @source_header, @previous = options[:source_header], options[:previous].try(:dup)

      previous.try(:free_previous)
      super(source_row, options)
    end

    # @return [Hash] a map of `column_name => source_row[index_of_column_name]`
    def mapped_row
      return {} unless source_row
      @mapped_row ||= self.class.column_names.zip(source_row).to_h
    end

    # @return [Hash] a map of `column_name => attribute_before_override`
    def original_attributes
      @original_attributes ||= begin
        @default_changes = {}

        values = self.class.column_names.map.with_index do |column_name, column_index|
          value = self.class.format_cell(mapped_row[column_name], column_name, column_index)

          if value.present?
            Coercer.new(self.class.options(column_name), self).decode(value)
          else
            original_value = value
            value = instance_exec(value, &self.class.default_lambda(column_name))
            @default_changes[column_name] = [original_value, value]
            value
          end
        end
        self.class.column_names.zip(values).to_h
      end
    end

    # return [Hash] a map changes from {.column}'s default option': `column_name -> [value_before_default, default_set]`
    def default_changes
      original_attributes
      @default_changes
    end

    # Free `previous` from memory to avoid making a linked list
    def free_previous
      @previous = nil
    end

    # @return [Import] self, the row_model, as compared to {Mapper}
    def row_model
      self
    end

    class_methods do

      INSPECT_INSTANCE_VARIABLES = %i[@mapped_row @initialized_at @parent @context @previous].freeze
      def inspect_instance_variables
        INSPECT_INSTANCE_VARIABLES
      end

      # @return [Class] used for {Model::Children.has_many_relationships}
      def has_many_relationships_module
        Import
      end

      # See {Model#column}
      def column(column_name, options={})
        super
        define_attribute_method(column_name)
      end

      # Safe to override. Method applied to each cell by default
      #
      # @param cell [String] the cell's string
      # @param column_name [Symbol] the cell's column_name
      # @param column_index [Integer] the column_name's index
      def format_cell(cell, column_name, column_index)
        cell
      end

      # @return [Lambda] returns a Lambda: ->(original_value) { default_exists? ? default : original_value }
      def default_lambda(column_name)
        default = options(column_name)[:default]
        default.is_a?(Proc) ? ->(s) { instance_exec(&default) } : ->(s) { default.nil? ? s : default }
      end

      protected
      # Define default attribute method for a column
      # @param column_name [Symbol] the cell's column_name
      def define_attribute_method(column_name)
        define_method(column_name) { original_attributes[column_name] }
      end
    end
  end
end
