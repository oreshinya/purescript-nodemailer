'use strict';

import nodemailer from "nodemailer";

export function createTransporterImpl(config) {
  return nodemailer.createTransport(config);
}

export function sendMailImpl(message, transporter) {
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

export function createTestAccountImpl(onError, onSuccess) {
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

export function getTestMessageUrlImpl(nothing, just, info) {
  const result = nodemailer.getTestMessageUrl(info);
  return !result ? nothing : just(result);
}
