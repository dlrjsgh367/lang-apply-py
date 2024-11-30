enum Education {
  unspecified(value: 1, label: localization.unspecified),
  additional(value: 2, label: localization.addEducation);
  const Education({
    required this.value,
    required this.label,
  });

  final int value;
  final String label;
}



