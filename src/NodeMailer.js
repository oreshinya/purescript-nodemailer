'use strict';

const nodemailer = require('nodemailer');

exports.createTransporter = function(config) {
  return function() {
    return nodemailer.createTransport(config);
  }
}

exports._sendMail = function(message, transporter) {
  var msg = Object.assign({}, message);
  if (msg.attachments) {
    msg.attachments = msg.attachments.map(function (x) { return x.value0 });
  };
  return function(onError, onSuccess) {
    transporter.sendMail(msg, function(e) {
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
