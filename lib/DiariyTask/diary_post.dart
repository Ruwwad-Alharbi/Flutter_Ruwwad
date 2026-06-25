class DiaryPost {
  final String title;
  final String username;
  final String date;
  final String body;
  final double imageHeight;
  final int number;

  const DiaryPost({
    required this.title,
    required this.username,
    required this.date,
    required this.body,
    required this.imageHeight,
    required this.number,
  });
}

const String loremBody =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod '
    'tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim '
    'veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea '
    'commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit '
    'esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat '
    'non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.';