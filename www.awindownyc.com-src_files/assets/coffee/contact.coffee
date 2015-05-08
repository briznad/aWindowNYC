aWindow = aWindow or {}

aWindow.contact = do ->
  'use strict'

  send = (req) ->
    formType = _establishFormType req.params.typeOfContact

    return false if not formType or not _validate[formType] req.params

    $.ajax
      type: 'POST'
      url: '//formspree.io/awindownyc@gmail.com'
      data: req.params
      dataType: 'json'
      complete: _afterSend[formType]

  _establishFormType = (typeOfContact) ->
    switch typeOfContact
      when 'Subscribe to Newsletter'
        'newsletterSubscribe'
      when 'Contact Form Message'
        'contactPage'
      else
        false

  _validate =
    # email validation regex taken from http://stackoverflow.com/a/46181
    emailPattern: /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/

    newsletterSubscribe: (formFields) ->
      if _validate.emailPattern.test formFields.newsletterEmail
        true

      else
        aWindow.modal.open 'Please enter a valid e-mail address.',
          displayDuration   : 3000
          additionalClasses : ['contact-modal']

        false

    contactPage: ->
      true

  _afterSend =
    newsletterSubscribe: ->
      aWindow.modal.open 'Thank you for signing up for our newsletter.',
        reloadPage        : true
        displayDuration   : 3000
        additionalClasses : ['contact-modal']

    contactPage: ->
      aWindow.modal.open 'Thank you for contacting us and expressing interest to learn more about the project. We will respond shortly.',
        reloadPage        : true
        additionalClasses : ['contact-modal']

  send: send