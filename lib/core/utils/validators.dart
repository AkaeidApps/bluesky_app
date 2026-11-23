class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  static String? confirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? handle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Handle is required';
    }
    final clean = value.startsWith('@') ? value.substring(1) : value;
    if (clean.length < 3) {
      return 'Handle must be at least 3 characters';
    }
    if (clean.length > 30) {
      return 'Handle cannot exceed 30 characters';
    }
    final handleRegex = RegExp(r'^[a-zA-Z0-9_\.]+$');
    if (!handleRegex.hasMatch(clean)) {
      return 'Letters, numbers, underscores and dots only';
    }
    return null;
  }

  static String? displayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Display name is required';
    }
    if (value.trim().length > 64) {
      return 'Display name cannot exceed 64 characters';
    }
    return null;
  }
}
