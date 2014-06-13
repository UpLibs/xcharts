simple_regexp.dart
============

A Simple way to work with RegExp in Dart.


##Example

```dart


import 'package:simple_regexp/simple_regexp.dart';


void main(){

  String s = 'Date: 20140321' ;
  
  s = SimpleRegExp.replace(s, r'(\d\d\d\d)(\d\d)(\d\d)', r'year: $1 ; month: $2 ; day: $3') ;
  
  print(s) ;
  // Date: year: 2014 ; month: 03 ; day: 21

  String date = '20140325' ;

  date = SimpleRegExp.formatMask(date, 'dddd/dd/dd') ;
  
  print(date) ;
  // 2014/03/25


  String numb = '111 222333 44' ; 

  numb = SimpleRegExp.formatMask(numb, 'ddd.ddd.ddd-dd') ;
  
  print(numb) ;
  // 111.222.333-44
  
  String cel = '123 5551234' ;
   
  cel = SimpleRegExp.formatMask(cel, '(ddd) d+-dddd') ;
  
  print(cel) ;
  // (123) 555-1234


}


```

TODO
----

* More examples of usage.


CHANGELOG
---------

  * version: 0.1.6:
  GitHub integration.

  * version: 0.1.5:
  Added internal cache for computed mask of formatMask() function.

  * version: 0.1.4:
  Added formatMask() function. 

  * version: 0.1.3:
  Fixed some simple bugs. First stable version.

