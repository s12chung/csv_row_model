module CsvRowModel
  # Include this to with {Model} to have a RowModel for importing csvs.
  module Import
    extend ActiveSupport::Concern

    # Mapping of column type classes to a parsing lambda. These are applied after {Import.format_cell}.
    # Can pass custom Proc with :parse option.
    CLASS_TO_PARSE_LAMBDA = {
      nil => ->(s) { s },
      # inspired by https://github.com/MrJoy/to_bool/blob/5c9ed38e47c638725e33530ea1a8aec96281af20/lib/to_bool.rb#L23
      Boolean => ->(s) { s =~ /^(false|f|no|n|0|)$/i ? false : true },
      String  => ->(s) { s },
      Integer => ->(s) { s.to_i },
      Float   => ->(s) { s.to_f },
      Date    => ->(s) { s.present? ? Date.parse(s) : s }
    }

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
            instance_exec(value, &self.class.parse_lambda(column_name))
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

      # @return [Lambda, Proc] returns the Lambda/Proc given in the parse option or:
      # ->(original_value) { parse_proc_exists? ? parsed_value : original_value  }
      def parse_lambda(column_name)
        options = options(column_name)
        parse_lambda = options[:parse] || CLASS_TO_PARSE_LAMBDA[options[:type]]
        return parse_lambda if parse_lambda
        raise ArgumentError.new("type must be #{CLASS_TO_PARSE_LAMBDA.keys.reject(:nil?).join(", ")}")
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
