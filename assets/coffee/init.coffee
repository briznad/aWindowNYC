aWindow = aWindow or {}

aWindow.init = do ->
  'use strict'

  aWindow.modelBuildr.init ->
    # load router controller
    do aWindow.router