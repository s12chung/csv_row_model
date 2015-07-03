module CsvRowModel
  module Base
    extend ActiveSupport::Concern

    def to_json
      attributes.to_json
    end
  end
end