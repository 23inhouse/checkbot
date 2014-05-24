module NumberHelper
  include ActionView::Helpers::NumberHelper

  def number_to_money(number, options = {})
    return if number.blank?
    number = BigDecimal(number.to_s)
    options.merge!(:precision => number.round(2) == number.round(0) ? 0 : 2)
    number_to_currency(number, options)
  end
end
