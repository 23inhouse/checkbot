module Checkbot
  module Taggable
    attr_accessor :tags

    def set_tags(tags)
      @tags = tags || []
    end

    def tag_names
      return '' if !tags?
      '{ '+tags.collect(&:name).join(', ')+' }'
    end

    def tags?
      !tags.empty?
    end
  end
end
