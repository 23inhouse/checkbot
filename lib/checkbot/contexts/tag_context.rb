module Checkbot
  class TagContext
    include Contextable

    alias_method :tags, :contextables

    def add(tag)
      existing_tag = find(tag.name)
      return existing_tag if existing_tag

      tags << tag
      tag
    end
  end
end
