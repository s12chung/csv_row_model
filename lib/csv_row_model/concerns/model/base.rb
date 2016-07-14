module CsvRowModel
  module Model
    module Base
      extend ActiveSupport::Concern

      included do
        attr_reader :context, :parent, :initialized_at
      end

      # @param [Hash] options
      # @option options [String] :parent if the instance is a child, pass the parent
      # @option options [Hash] :context extra data you want to work with the model
      def initialize(options={})
        @initialized_at = DateTime.now
        @parent = options[:parent]
        @context =  OpenStruct.new(options[:context] || {})
      end

      # Safe to override.
      # @return [Boolean] returns true, if this instance should be skipped
      def skip?
        !valid?
      end

      # Safe to override.
      # @return [Boolean] returns true, if the entire csv file should stop reading
      def abort?
        false
      end

      def eql?(other)
        other.try(:attributes) == attributes
      end

      def hash
        attributes.hash
      end
    end
  end
end