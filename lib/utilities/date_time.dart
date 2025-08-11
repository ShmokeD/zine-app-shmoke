const List<String> months = [
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MAY',
  'JUN',
  'JUL',
  'AUG',
  'SEP',
  'OCT',
  'NOV',
  'DEC'
];

//===============================Newer CODE=========================================//
bool isPastEvent(DateTime eventDate) {
  DateTime today = DateTime.now();
  DateTime eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
  DateTime todayDate = DateTime(today.year, today.month, today.day);

  return eventDay
      .isBefore(todayDate); // Returns true if the event is in the past
}




String getChatTime(DateTime dateTime) {
  return '${dateTime.hour}:${dateTime.minute >= 10 ? dateTime.minute : '0${dateTime.minute}'}';
}

String getChatDate(DateTime dateTime) {

  return months[dateTime.month - 1];
}

String validShowDate(DateTime timeStamp) {
  return '${timeStamp.day} ${months[timeStamp.month - 1]} ${timeStamp.year}';
}

String getLastSeenFormat(int timeStamp) {
  try {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timeStamp);
    DateTime now = DateTime.now();

    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));

    if (dateTime.isAfter(today)) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (dateTime.isAfter(yesterday)) {
      return 'Yesterday';
    } else {
      return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year.toString().substring(2)}';
    }
  } catch (e) {
    return "";
  }
}
