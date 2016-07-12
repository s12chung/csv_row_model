module CsvRowModel
  module Concerns
    module HiddenModule
      extend ActiveSupport::Concern

      class_methods do
        def hidden_module
          @hidden_module ||= Module.new.tap { |mod| include mod }
        end

        def define_proxy_method(*args, &block)
          hidden_module.send(:define_method, *args, &block)
        end
      end
    end
  end
end