enum File {
  empty(value: 1, label: localization.notExists),
  nonEmpty(value: 2, label: localization.exists);
  const File({
    required this.value,
    required this.label,
  });

  final int value;
  final String label;
}



