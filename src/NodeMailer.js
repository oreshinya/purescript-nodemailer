'use strict';

const nodemailer = require('nodemailer');

exports.createTransporterImpl = function(config) {
  return nodemailer.createTransport(config);
}

exports.sendMailImpl = function(message, transporter) {
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

exports.createTestAccountImpl = function(onError, onSuccess) {
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

exports.getTestMessageUrlImpl = function(nothing, just, info) {
  const result = nodemailer.getTestMessageUrl(info);
  return !result ? nothing : just(result);
}
