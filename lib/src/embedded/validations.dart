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
        return 'Pillar name must match pattern: ${pillarNameRegExp.pattern}';
      }
      return null;
    } else {
      return 'Value is null';
    }
  }

  static String? proposalUrl(String? value) {
    if (value != null) {
      if (value.isEmpty) {
        return 'Proposal URL can\'t be empty';
      }
      if (!proposalUrlRegExp.hasMatch(value)) {
        return 'Proposal URL does not match pattern: ${proposalUrlRegExp.pattern}';
      }
      return null;
    } else {
      return 'Value is null';
    }
  }

  static String? proposalName(String? value) {
    if (value != null) {
      if (value.isEmpty) {
        return 'Proposal name can\'t be empty';
      }
      if (value.length > proposalNameMaxLength) {
        return 'Proposal name must have maximum $proposalNameMaxLength characters';
      }
      return null;
    } else {
      return 'Value is null';
    }
  }

  static String? proposalDescription(String? value) {
    if (value != null) {
      if (value.isEmpty) {
        return 'Proposal description can\'t be empty';
      }
      if (value.length > proposalDescriptionMaxLength) {
        return 'Proposal description must have maximum $proposalDescriptionMaxLength characters';
      }
      return null;
    } else {
      return 'Value is null';
    }
  }
}
