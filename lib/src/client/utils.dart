bool validateWsConnectionURL(String url) {
  return (Uri.tryParse(url) != null) &&
      Uri.parse(url).isAbsolute &&
      Uri.parse(url).hasPort &&
      (Uri.parse(url).scheme == 'ws' || Uri.parse(url).scheme == 'wss');
}
