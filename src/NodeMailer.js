'use strict';

const nodemailer = require('nodemailer');

exports.createTransporter = function(config) {
  return function() {
    return nodemailer.createTransport(config);
  }
}

exports._sendMail = function(message, transporter) {
  return function(onError, onSuccess) {
    transporter.sendMail(message, function(e, info) {
      if (e) {
        onError(e);
      } else {
        onSuccess(info);
      }
    });
    return function(cancelError, onCancelerError, onCancelerSuccess) {
      onCancelerSuccess({});
    }
  }
}

exports._createTestAccount = function(onError, onSuccess) {
  nodemailer.createTestAccount(function(e, account) {
    if (e) {
      onError(e);
    } else {
      onSuccess(account);
    }
  });
  return function(cancelError, onCancelerError, onCancelerSuccess) {
    onCancelerSuccess({});
  }
}

exports._getTestMessageUrl = function(nothing, just, info) {
  const result = nodemailer.getTestMessageUrl(info);
  return !result ? nothing : just(result);
}
