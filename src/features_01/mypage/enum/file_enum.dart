enum File {
  empty(value: 1, label: '없음'),
  nonEmpty(value: 2, label: '있음');
  const File({
    required this.value,
    required this.label,
  });

  final int value;
  final String label;
}



