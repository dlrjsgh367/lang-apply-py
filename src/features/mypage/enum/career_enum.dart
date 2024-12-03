enum Career {

  entry(value: 0, label: localization.newGraduate),
  experienced(value: 1, label: localization.experienced);
  const Career({
    required this.value,
    required this.label,
  });

  final int value;
  final String label;
}



