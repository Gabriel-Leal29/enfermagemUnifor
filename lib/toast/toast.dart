import 'package:flutter/material.dart';
import 'show_toast.dart';

void showToastInfo(BuildContext context, String message) {
  showToast(context, message: message, type: ToastType.info);
}

void showToastError(BuildContext context, String message) {
  showToast(context, message: message, type: ToastType.error);
}

void showToastSuccess(BuildContext context, String message) {
  showToast(context, message: message, type: ToastType.success);
}

void showToastWarning(BuildContext context, String message) {
  showToast(context, message: message, type: ToastType.warning);
}
