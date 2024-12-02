enum Education {
  unspecified(value: 1, label: '미기재'),
  additional(value: 2, label: '학력추가');
  const Education({
    required this.value,
    required this.label,
  });

  final int value;
  final String label;
}



