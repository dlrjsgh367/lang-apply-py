enum File {
  empty(value: 1, label: localization.none),
  nonEmpty(value: 2, label: localization.available);
  const File({
    required this.value,
    required this.label,
  });

  final int value;
  final String label;
}



