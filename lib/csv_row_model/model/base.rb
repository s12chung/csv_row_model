module CsvRowModel
  module Model
    module Base
      extend ActiveSupport::Concern

      included do
        # @return [Model] return the parent, if this instance is a child
        attr_reader :parent

        # @return [DateTime] return when self has been intialized
        attr_reader :initialized_at

        validate_attributes :parent
      end

      # @param [NilClass] source not used here, see {Input}
      # @param [Hash] options
      # @option options [String] :parent if the instance is a child, pass the parent
      def initialize(source=nil, options={})
        @initialized_at = DateTime.now
        @parent = options[:parent]
      end

      # Safe to override.
      #
      # @return [Boolean] returns true, if this instance should be skipped
      def skip?
        !valid?
      end

      # Safe to override.
      #
      # @return [Boolean] returns true, if the entire csv file should stop reading
      def abort?
        false
      end
    end
  end
end