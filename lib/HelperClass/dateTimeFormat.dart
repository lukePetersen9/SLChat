class DateTimeFormat {
  String getDisplayDateText(DateTime sent, DateTime now) {
    if (now.difference(sent).inHours < 24) {
      return (sent.hour % 12 == 0 ? '12' : (sent.hour % 12).toString()) +
          ':' +
          (sent.minute < 10
              ? '0' + sent.minute.toString()
              : sent.minute.toString()) +
          (sent.hour > 11 && sent.hour < 23 ? ' pm' : ' am');
    } else if (now.difference(sent).inDays < 7) {
      // return now.difference(sent).inDays.toString();
      return _weekdayAbreviation(sent.weekday) +
          ', ' +
          (sent.hour % 12 == 0 ? '12' : (sent.hour % 12).toString()) +
          ':' +
          (sent.minute < 10
              ? '0' + sent.minute.toString()
              : sent.minute.toString()) +
          (sent.hour > 11 && sent.hour < 23 ? ' pm' : ' am');
    } else {
      return _monthAbreviation(sent.month) +
          ' ' +
          sent.day.toString() +
          ', ' +
          (sent.hour % 12 == 0 ? '12' : (sent.hour % 12).toString()) +
          ':' +
          (sent.minute < 10
              ? '0' + sent.minute.toString()
              : sent.minute.toString());
    }
  }

  String _weekdayAbreviation(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'idk';
    }
  }

  String _monthAbreviation(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sept';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return 'idk';
    }
  }
}
