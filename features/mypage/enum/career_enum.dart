enum Career {

  entry(value: 0, label: '신입'),
  experienced(value: 1, label: '경력');
  const Career({
    required this.value,
    required this.label,
  });

  final int value;
  final String label;
}



