aWindow = aWindow or {}

aWindow.tracking = do ->
  'use strict'

  init = ->

  # fire GA event for each page load
  trackPage = (req) ->
    _gaq.push [
      '_trackPageview'
      req
    ]

  addToCart = ->
    _gaq.push [
      '_trackEvent'
      'cart'
      'add to cart'
      window.location.pathname
      undefined
      true
    ]

  heliumCartEvents = ->
    # Helium's js events are jank
    # and they appear to call stopPropagation
    # to prevent events from bubbling to body
    # therefore, I must register specific events
    # each time the cart is shown

    counter = 0

    ajaxBuster = (selector, action, postClickCallback = ->) ->
      if $(selector).length
        $(selector).on 'click', ->
          _gaq.push [
            '_trackEvent'
            'cart'
            action
            unless action is 'remove from cart' then window.location.pathname else $(this).parent('.paper_row').parent().attr('data-id')
            undefined
            true
          ]

          do postClickCallback
      else if counter < 3000
        counter++

        t = setTimeout ->
          ajaxBuster selector, action, postClickCallback
        , 100

    # remove item from cart
    ajaxBuster '.paper_row .remove.item', 'remove from cart', ->
      # click "close" button when cart is empty
      ajaxBuster '#helium_checkout_server_error .helium_checkout_button', 'close cart'

    # click "place order" button in cart
    ajaxBuster '#checkout_submit', 'place order'

    # click "continue shopping" button in cart
    ajaxBuster '#checkout_cancel', 'continue shopping'

  init              : init
  trackPage         : trackPage
  addToCart         : addToCart
  heliumCartEvents  : heliumCartEvents