var aWindow;

aWindow = aWindow || {};

aWindow.contact = (function() {
  'use strict';
  var send, _afterSend, _establishFormType, _validate;
  send = function(req) {
    var formType;
    formType = _establishFormType(req.params.typeOfContact);
    if (!formType || !_validate[formType](req.params)) {
      return false;
    }
    return $.ajax({
      type: 'POST',
      url: '//formspree.io/awindownyc@gmail.com',
      data: req.params,
      dataType: 'json',
      complete: _afterSend[formType]
    });
  };
  _establishFormType = function(typeOfContact) {
    switch (typeOfContact) {
      case 'Subscribe to Newsletter':
        return 'newsletterSubscribe';
      case 'Contact Form Message':
        return 'contactPage';
      default:
        return false;
    }
  };
  _validate = {
    emailPattern: /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/,
    newsletterSubscribe: function(formFields) {
      if (_validate.emailPattern.test(formFields.newsletterEmail)) {
        return true;
      } else {
        aWindow.modal.open('Please enter a valid e-mail address.', {
          displayDuration: 3000,
          additionalClasses: ['contact-modal']
        });
        return false;
      }
    },
    contactPage: function() {
      return true;
    }
  };
  _afterSend = {
    newsletterSubscribe: function() {
      return aWindow.modal.open('Thank you for signing up for our newsletter.', {
        reloadPage: true,
        displayDuration: 3000,
        additionalClasses: ['contact-modal']
      });
    },
    contactPage: function() {
      return aWindow.modal.open('Thank you for contacting us and expressing interest to learn more about the project. We will respond shortly.', {
        reloadPage: true,
        additionalClasses: ['contact-modal']
      });
    }
  };
  return {
    send: send
  };
})();
