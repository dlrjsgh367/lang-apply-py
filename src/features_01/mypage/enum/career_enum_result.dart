enum Career {

  entry(value: 0, label: localization.newbie),
  experienced(value: 1, label: localization.career);
  const Career({
    required this.value,
    required this.label,
  });

  final int value;
  final String label;
}



