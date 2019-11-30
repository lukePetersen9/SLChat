import 'dart:core';

class User {
  String f;
  String l;
  String u;
  String e;
  String p;
  User(this.f, this.l, this.e, this.p, this.u);

  String get firstName {
    return f;
  }

  set firstName(String n) {
    f = n;
  }

  String get lastName {
    return l;
  }

  set lastName(String n) {
    l = n;
  }

  String get userName {
    return u;
  }

  set userName(String n) {
    u = n;
  }

  String get email {
    return e;
  }

  set email(String n) {
    e = n;
  }

  String get image {
    return p;
  }

  set image(String n) {
    p = n;
  }
}
