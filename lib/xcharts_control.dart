part of xcharts ;


abstract class XChartsControl {
  
  static const int CONTROL_POSITION_NORTH = 0 ;
  static const int CONTROL_POSITION_SOUTH = 1 ;
  static const int CONTROL_POSITION_EAST  = 2 ;
  static const int CONTROL_POSITION_WEST  = 3 ;
  
  int position ;
  
  int width ;
  int height ;
  
  XChartsControl(this.position, this.width, this.height) ;
  
  List<XChartsElement> drawControl(XCharts xcharts, CanvasRenderingContext2D context, int chartWidth, int chartHeight) ;
  
}

abstract class XChartsControlElement extends XChartsElement {
  
  XChartsControl _control ;
  XChartsControlElement(this._control, num x, num y, num width, num height) : super(x, y, width, height);
  
  void mouseMove(XCharts chart, num x, num y) {}
  void mouseClick(XCharts chart, num x, num y) {}
  void mousePress(XCharts chart, num x, num y) {}
  void mouseRelease(XCharts chart, num x, num y) {}
  
}

class XChartsControlTimeline extends XChartsControl {
  
  static const int POSITION_NORTH = XChartsControl.CONTROL_POSITION_NORTH ;
  static const int POSITION_SOUTH = XChartsControl.CONTROL_POSITION_SOUTH ;
  
  static const int SERIES_DATA_MAX = 0 ;
  static const int SERIES_DATA_MIN = 1 ;
  static const int SERIES_DATA_MEAN = 2 ;
  static const int SERIES_DATA_MIN_MAX_MEAN = 3 ;
  
  ///////////////////////
  
  final XChartsTimelineDataHandler _timelineDataHandler ;
  
  int seriesDataType = SERIES_DATA_MAX ;

  String colorBackground = 'rgba(0,0,0, 0.10)' ;
  String colorMax = '#ff0000' ;
  String colorMin = '#ffff00' ;
  String colorMean = '#0000ff' ;
  
  double colorAlpha = 0.50 ;
  
  XChartsControlTimeline(this._timelineDataHandler, int position, int height, [this.seriesDataType = SERIES_DATA_MAX]) : super(position, -1, height) ;

  XChartsTimelineDataHandler get timelineDataHandler => this._timelineDataHandler ;
  
  bool get isDataLoaded => this._timelineDataHandler.isDataLoaded ;
  
  List<XChartsDataSeries> getDataSeries(XCharts xcharts) {
    if (!isDataLoaded) return [] ;
    
    //timelineDataHandler.loadData() ;
    return timelineDataHandler.getSeries() ;
  }
  
  XChartsControlElementTimeline _controlElement ;
  
  @override
  List<XChartsElement> drawControl(XCharts xcharts, CanvasRenderingContext2D context, int chartWidth, int chartHeight) {
    
    int x = 0 ;
    int y = this.position == POSITION_NORTH ? 0 : chartHeight-height ;
    int w = chartWidth ;
    int h = height ;
    
    double xAxisX = x+2.0 ;
    double xAxisY = y+h + 2.0 ;
    double xAxisW = w - 4.0 ;
    double xAxisH = h - 4.0 ;
    
    context.fillStyle = colorBackground ;
    context.fillRect(x,y , w,h) ;
    
    /////////////////////

    double minValX = null ;
    double maxValX = null ;
    double minValY = null ;
    double maxValY = null ;
    
    List<XChartsDataSeries> series = getDataSeries(xcharts) ;
    
    List<XChartsData> allData = XCharts.getAllSeriesData(series) ;
    
    if (allData == null || allData.isEmpty) return null ;
    
    for (var d in allData) {
      if (maxValX == null || maxValX < d.valueX) maxValX = d.valueX.toDouble() ;
      if (minValX == null || minValX > d.valueX) minValX = d.valueX.toDouble() ;
            
      if (maxValY == null || maxValY < d.valueY) maxValY = d.valueY.toDouble() ;
      if (minValY == null || minValY > d.valueY) minValY = d.valueY.toDouble() ;
    }
    
    if (minValX > timelineDataHandler.initTime) minValX = timelineDataHandler.initTime.toDouble() ;
    if (maxValX < timelineDataHandler.endTime) maxValX = timelineDataHandler.endTime.toDouble() ;
    
    ///////////////////////
    
    String colorMax = XCharts.color2rgba(this.colorMax, colorAlpha) ;
    String colorMin = XCharts.color2rgba(this.colorMin, colorAlpha) ;
    String colorMean = XCharts.color2rgba(this.colorMean, colorAlpha) ;
    
    if ( seriesDataType == SERIES_DATA_MAX ) {
      _drawControlImplem(xcharts, context, x, y, w, h, minValX, maxValX, minValY, maxValY, XCharts.getAllSeriesDataMax(series) , colorMax) ;  
    }
    else if ( seriesDataType == SERIES_DATA_MIN) {
      _drawControlImplem(xcharts, context, x, y, w, h, minValX, maxValX, minValY, maxValY, XCharts.getAllSeriesDataMin(series) , colorMin) ;  
    }
    else if ( seriesDataType == SERIES_DATA_MEAN ) {
      _drawControlImplem(xcharts, context, x, y, w, h, minValX, maxValX, minValY, maxValY, XCharts.getAllSeriesDataMean(series) , colorMean) ;  
    }
    else if ( seriesDataType == SERIES_DATA_MIN_MAX_MEAN ) {
      _drawControlImplem(xcharts, context, x, y, w, h, minValX, maxValX, minValY, maxValY, XCharts.getAllSeriesDataMax(series) , colorMax) ;
      _drawControlImplem(xcharts, context, x, y, w, h, minValX, maxValX, minValY, maxValY, XCharts.getAllSeriesDataMin(series) , colorMin) ;
      _drawControlImplem(xcharts, context, x, y, w, h, minValX, maxValX, minValY, maxValY, XCharts.getAllSeriesDataMean(series) , colorMean , true) ;
    }
    
    int timeRange = (maxValX - minValX).toInt() ;
    
    int selInit =  ( w * ( (this._timelineDataHandler.selectInitTime - minValX) / timeRange ) ).toInt() ;
    int selEnd =  ( w * ( (this._timelineDataHandler.selectEndTime - minValX) / timeRange ) ).toInt() ;
    
    context.fillStyle = 'rgba(0,0,0 , 0.20)' ;
    context.fillRect(x+selInit,y , selEnd-selInit,h) ;
    
    if ( _controlElement == null || !_controlElement.sameDimension(x, y, w, h) ) {
      _controlElement = new XChartsControlElementTimeline(this, x, y, w, h) ;  
    }
        
    return [_controlElement] ;
  }
  
  void _drawControlImplem(XCharts xcharts, CanvasRenderingContext2D context, int x , int y , int w , int h , double minValX, double maxValX, double minValY, double maxValY, List<XChartsData> allData, String color, [bool line = false]) {
    if (allData.isEmpty) return ;
    
    double xAxisX = x+2.0 ;
    double xAxisY = y+h + 2.0 ;
    double xAxisW = w - 4.0 ;
    double xAxisH = h - 4.0 ;
    
    double valXrange = maxValX - minValX ;
    double valYrange = maxValY - minValY ;
    
    List<Point> points = [] ;
    
    for (var d in allData) {
      num px = xAxisX + ( ( (d.valueX-minValX)/valXrange ) * xAxisW ) ;
      num py = (xAxisY-h) + ( ( 1-(d.valueY-minValY)/valYrange ) * xAxisH ) ;
      
      points.add( new Point( px , py ) ) ;
    }
    
    if (line) {
      context.strokeStyle = color ;
    
      context.beginPath() ;
      
      for (var p in points) {
        context.lineTo(p.x, p.y) ;
      }
              
      context.stroke() ;
    }
    else {
      context.fillStyle = color ;
    
      context.beginPath() ;
      
      for (var p in points) {
        context.lineTo(p.x, p.y) ;
      }
      
      context.lineTo(points.last.x, xAxisY) ;
      context.lineTo(points.first.x, xAxisY) ;
              
      context.fill() ;
    }
  }
  
}

class XChartsControlElementTimeline extends XChartsControlElement {
  
  XChartsControlElementTimeline(XChartsControlTimeline control, num x, num y, num width, num height) : super(control, x, y, width, height);
  
  @override
  void mouseClick(XCharts chart, num x, num y) {
    print("click> $x ; $y") ;
    
    _setSelection(chart, x, y) ;
    _loadData() ;  
  }
  
  void _loadData() {
    this.control.timelineDataHandler.setAutoUpdateDataAndLoadData(true) ;
  }
  
  XChartsControlTimeline get control => this._control as XChartsControlTimeline ;

  @override
  void mouseMove(XCharts chart, num x, num y) {
    print("move> $x ; $y > $_pressed") ;

    if (_pressed && chart._mousePressed) _setSelection(chart, x, y) ;
  }
  
  void _setSelection(XCharts chart, num x, num y) {
    double ratio = x / this.width ;
    
    if (ratio > 1) ratio = 1.0 ;
    else if (ratio < 0) ratio = 0.0 ;
    
    double diffInit = this.control.timelineDataHandler.selectInitTimeAsRatio - ratio ;
    double diffEnd = ratio - this.control.timelineDataHandler.selectEndTimeAsRatio ;
    
    if (diffInit < 0) diffInit = -diffInit ;
    if (diffEnd < 0) diffEnd = -diffEnd ;
    
    control.timelineDataHandler.setAutoUpdateData(false) ;
    
    if ( diffInit < diffEnd ) {
      this.control.timelineDataHandler.setSelectInitTimeByRatio(ratio) ;  
    }
    else {
      this.control.timelineDataHandler.setSelectEndTimeByRatio(ratio) ;
    }
    
    chart.requestRepaint() ;
  }
  
  bool _pressed = false ;
  
  @override
  void mousePress(XCharts chart, num x, num y) {
    print("press> $x ; $y") ;
    _pressed = true ;
  }
  
  @override
  void mouseRelease(XCharts chart, num x, num y) {
    print("release> $x ; $y") ;
    _pressed = false ;
    
    _loadData() ;
  }
  
}


