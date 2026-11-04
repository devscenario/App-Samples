/// Email rule mirrored from the CMP sample's `SampleValidation`: has `@`, a `.`
/// after the `@`, no whitespace, and the dot isn't the last character.
bool isValidEmail(String email) {
  if (email.isEmpty || email.contains(RegExp(r'\s'))) return false;
  final at = email.indexOf('@');
  if (at <= 0) return false;
  final dot = email.indexOf('.', at);
  if (dot < 0) return false;
  if (dot == email.length - 1) return false;
  return true;
}
