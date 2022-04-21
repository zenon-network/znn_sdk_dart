import 'package:znn_sdk_dart/src/embedded/constants.dart';

class Validations {
  static String? tokenName(String? value) {
    if (value != null) {
      if (value.isEmpty) {
        return 'Token name can\'t be empty';
      }
      if (!tokenNameRegExp.hasMatch(value)) {
        return 'Token name must contain only alphanumeric characters';
      }
      if (value.length > tokenNameMaxLength) {
        return 'Token name must have maximum $tokenNameMaxLength characters';
      }
      return null;
    } else {
      return 'Value is null';
    }
  }

  static String? tokenSymbol(String? value) {
    if (value != null) {
      if (value.isEmpty) {
        return 'Token symbol can\'t be empty';
      }
      if (!tokenSymbolRegExp.hasMatch(value)) {
        return 'Token symbol must match pattern: ${tokenSymbolRegExp.pattern}';
      }
      if (value.length > tokenSymbolMaxLength) {
        return 'Token symbol must have maximum $tokenSymbolMaxLength characters';
      }
      if (tokenSymbolExceptions.contains(value)) {
        return 'Token symbol must not be one of the following: ${tokenSymbolExceptions.join(', ')}';
      }
      return null;
    } else {
      return 'Value is null';
    }
  }

  static String? tokenDomain(String? value) {
    if (value != null) {
      if (value.isEmpty) {
        return 'Token domain can\'t be empty';
      }
      if (!tokenDomainRegExp.hasMatch(value)) {
        return 'Domain is not valid';
      }
      return null;
    } else {
      return 'Value is null';
    }
  }

  static String? pillarName(String? value) {
    if (value != null) {
      if (value.isEmpty) {
        return 'Pillar name can\'t be empty';
      }
      if (!pillarNameRegExp.hasMatch(value)) {
        return 'Pillar name must match pattern : ${pillarNameRegExp.pattern}';
      }
      if (value.length > pillarNameMaxLength) {
        return 'Pillar name must have maximum $pillarNameMaxLength characters';
      }
      return null;
    } else {
      return 'Value is null';
    }
  }

  static String? projectName(String? value) {
    if (value != null) {
      if (value.isEmpty) {
        return 'Project name can\'t be empty';
      }
      if (value.length > projectNameMaxLength) {
        return 'Project name must have maximum $projectNameMaxLength characters';
      }
      return null;
    } else {
      return 'Value is null';
    }
  }

  static String? projectDescription(String? value) {
    if (value != null) {
      if (value.isEmpty) {
        return 'Project description can\'t be empty';
      }
      if (value.length > projectDescriptionMaxLength) {
        return 'Project description must have maximum $projectDescriptionMaxLength characters';
      }
      return null;
    } else {
      return 'Value is null';
    }
  }
}
