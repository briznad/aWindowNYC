aWindow = aWindow or {}

aWindow.init = do ->
  'use strict'

  # load templates
  aWindow.template.init ->
    # retrieve json and build document model
    aWindow.modelBuildr.init ->
      # load router controller
      do aWindow.router.init

  # init lightbox
  do aWindow.lightbox.init