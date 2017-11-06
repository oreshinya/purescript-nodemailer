'use strict';

const nodemailer = require('nodemailer');

exports.createTransporter = function(config) {
  return function() {
    return nodemailer.createTransport(config);
  }
}

exports._sendMail = function(message, transporter) {
  return function(onError, onSuccess) {
    transporter.sendMail(message, function(e) {
      if (e) {
        onError(e);
      } else {
        onSuccess({});
      }
    });
    return function(cancelError, onCancelerError, onCancelerSuccess) {
      onCancelerSuccess({});
    }
  }
}
