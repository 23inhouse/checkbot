module Checkbot
  class MixedPackContext
    include Contextable

    alias_method :mixed_packs, :contextables

    def add(mixed_pack)
      existing_mixed_pack = find(mixed_pack.name)
      return existing_mixed_pack if existing_mixed_pack

      mixed_packs << mixed_pack
      mixed_pack
    end
  end
end