module WithContext
  extend ActiveSupport::Concern

  class_methods do
    # with_context "context_name1", "context_name2" { <block> }
    # is short hand for:
    # context "context_name1" { include_context "context_name1"; <block> }
    # context "context_name2" { include_context "context_name2"; <block> }...
    def with_context(*context_names, &block)
      context_names.each do |context_name|
        context context_name do
          include_context context_name
          instance_exec(&block)
        end
      end
    end
  end
end