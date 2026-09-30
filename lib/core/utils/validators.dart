abstract final class Validators {
  static String? requiredText(String? text) =>
      text == null || text.trim().isEmpty ? 'This field is required.' : null;
  static String? nonNegative(String? text) {
    final value = double.tryParse(text?.trim() ?? '');
    return value == null || !value.isFinite || value < 0
        ? 'Enter a number of zero or more.'
        : null;
  }

  static String? positive(String? text) {
    final value = double.tryParse(text?.trim() ?? '');
    return value == null || !value.isFinite || value <= 0
        ? 'Enter a number greater than zero.'
        : null;
  }
}
