def smp_with_2_2008_merlots_subtotal(subtotal)
  @check_bot.cart = read_cart_input(@seller, %(
            #2[#1P(2008 Merlot)] [
              #2P(2008 Merlot $20)
            ]
  ))

  read_cart_output(@seller, %(
            #2[#1P(2008 Merlot)] [
              #2P(2008 Merlot $20)
            ]
                  subtotal => $#{subtotal}
  ))
end

def smp_with_2_2008_merlots_shipping(shipping)
  @check_bot.cart = read_cart_input(@seller, %(
            #2[#1P(2008 Merlot)] [
              #2P(2008 Merlot $20)
            ]
  ))

  read_cart_output(@seller, %(
            #2[#1P(2008 Merlot)] [
              #2P(2008 Merlot $20)
            ]
                  shipping => $#{shipping}
  ))
end
