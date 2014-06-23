# Checkbot

Checkbot is a an extraction of a discount calculator from a Rails project.
Once you tell it about the available products, discounts and cart items it
will try to find the optimum discounts to apply so the customer is charged
the lowest price.

Discounts can be fixed price, amount off or percentage off, this can be
applied to either the price or shipping cost. The discount can be applied
based on the number of items in the cart or the dollar amount spent. The
discount can be applied to a Product, a Pack or a Tag.

Products can be grouped in Packs. Both Products and Packs can be tagged to
create arbitrary groupings. Both Products and Packs can be excluded from
counting towards or receiving discounts.

It would take too long to brute force check all possible combinations, so
fitness and hill climbing algorithms are used to calculate the optimum price*.

*It may not give the optimum price. (Edge cases are listed in the tests)

## Installation

Add this line to your application's Gemfile:

    gem 'checkbot'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install checkbot

## Example

```html
                     --- products ---

    2008 Cabernet     $25 { wine, 2008, Cabernet, Red, shipping }
    2008 Chardonnay   $15 { wine, 2008, Chardonnay }
    2008 Merlot       $20 { wine, 2008, Merlot, Red, shipping }
    2020 Cleanskin    $7  { wine, 2020, Cleanskin }

cleanskin pack [#12P(2020 Cleanskin)] [0000] { wine } -> D$50

                    --- discounts ---

                   #12T(wine)+ -> D-10%
              $200T(shipping)+ -> Sh-50%
               #24T(shipping)+ -> Sh-100%
                    #12T(Red)+ -> D-20%
                    #12T(2008) -> D-25%
                    #12T(2009) -> D-$25

                    --- test cart ---

    #6(2008 Cabernet $25)
    #6(2008 Chardonnay $15)
    #6(2008 Merlot $20)
    #1(cleanskin pack) [
      #12(2020 Cleanskin $7)
    ]

                --- expected cart ---

    #6(2008 Cabernet $25)      -> $150 ($112.50)
    #6(2008 Chardonnay $15)    -> $90 ($81)
    #6(2008 Merlot $20)        -> $120 ($90)
    #1(cleanskin pack) [
      #12(2020 Cleanskin $7)
    ]                          -> $50
                      subtotal => $333.50
                      shipping => $24

           --- actual result cart ---

    #6(2008 Cabernet $25)      -> $150 ($112.50)       sh -> $6
    #6(2008 Chardonnay $15)    -> $90 ($81)            sh -> $6
    #6(2008 Merlot $20)        -> $120 ($90)           sh -> $6
    #1(cleanskin pack) [
      #12(2020 Cleanskin $7)
    ]                          -> $50                  sh -> $12
                   sh discount => -$6.00
                      subtotal => $333.50
                      shipping => $24.00
                         total => $357.50
```

## Usage

TODO: Write usage instructions here

## Acknowledgements

The requirements specifications for this algorithm were originally by [Momoko Saunders](https://github.com/mrmomoko).
The original solution was developed by [Robert Wolf](https://github.com/cvg131072).

## Contributing

1. Fork it ( https://github.com/23inhouse/checkbot/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
