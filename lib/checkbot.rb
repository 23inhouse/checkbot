require 'checkbot/version'

require 'checkbot/utilities/money'
require 'checkbot/utilities/percentage'

require 'checkbot/models/discountable'
require 'checkbot/models/taggable'

require 'checkbot/models/pack'

require 'checkbot/models/cart'
require 'checkbot/models/cart_item'
require 'checkbot/models/discount'
require 'checkbot/models/mixed_pack'
require 'checkbot/models/packable'
require 'checkbot/models/product'
require 'checkbot/models/tag'
require 'checkbot/models/tally'

require 'checkbot/interpreters/interpretable'

require 'checkbot/interpreters/money_interpreter'
require 'checkbot/interpreters/percentage_interpreter'

require 'checkbot/interpreters/discountable_interpreter'
require 'checkbot/interpreters/savings_interpreter'
require 'checkbot/interpreters/taggable_interpreter'

require 'checkbot/interpreters/cart_item_interpreter'
require 'checkbot/interpreters/discount_interpreter'
require 'checkbot/interpreters/mixed_pack_interpreter'
require 'checkbot/interpreters/packable_interpreter'
require 'checkbot/interpreters/product_interpreter'
require 'checkbot/interpreters/tally_interpreter'
require 'checkbot/interpreters/totals_interpreter'

require 'checkbot/interpreters/interpreter'

require 'checkbot/builders/packable_builder'

require 'checkbot/builders/cart_item_builder'
require 'checkbot/builders/discount_builder'
require 'checkbot/builders/mixed_pack_builder'
require 'checkbot/builders/product_builder'
require 'checkbot/builders/tag_builder'
require 'checkbot/builders/tally_builder'
