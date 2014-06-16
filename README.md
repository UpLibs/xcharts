xcharts.dart
============

Another Charts library.


##Example

```dart


import 'package:xcharts/xcharts.dart';

void main() {
  
  Element container = querySelector("#charts-div") ;
  
  XCharts xcharts = new XCharts(new XChartsTypeLine()) ;
  
  xcharts.addSeries(
      new XChartsDataSeries('test1' , [
                                       new XChartsData(1 , 10) ,
                                       new XChartsData(1 , 11) ,
                                       new XChartsData(2 , 12) ,
                                       new XChartsData(2 , 13) ,
                                       new XChartsData(3 , 14) ,
                                       new XChartsData(3 , 15) ,
                                       new XChartsData(2 , 15.1) ,
                                       new XChartsData(1 , 15.2) ,
                                       new XChartsData(1 , 16) ,
                                       ] )
  ) ;
  
  xcharts.addSeries(
      new XChartsDataSeries('test2' , [
                                       new XChartsData(0.5 , 10) ,
                                       new XChartsData(0.6 , 11) ,
                                       new XChartsData(1.6 , 12) ,
                                       new XChartsData(1.6 , 13) ,
                                       new XChartsData(2 , 14) ,
                                       new XChartsData(2.5 , 15) ,
                                       new XChartsData(2 , 15.1) ,
                                       new XChartsData(1.5 , 15.2) ,
                                       new XChartsData(1.1 , 16) ,
                                       ] )
  ) ;
  
  xcharts.showAt(container) ;
  

}


```

TODO
----

* More examples of usage.


CHANGELOG
---------

  * version: 0.1.3:
  Resize on window resize.
  
  * version: 0.1.2:
  Added bar charts support.
  
  * version: 0.1.1:
  Added heat map support.

  * version: 0.1.0:
  1st version. Only lines and dots charts.

  