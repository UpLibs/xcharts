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
  void mouseEnter(XCharts chart, num x, num y) {}
  void mouseLeave(XCharts chart, num x, num y) {}
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
  String colorMax = '#1E3D6B' ;
  String colorMin = '#00FFCD' ;
  String colorMean = '#000FFF' ;
  bool highlightLeftSelectionBorder = false ;
  bool highlightRightSelectionBorder = false ;  
  double colorAlpha = 0.50 ;
  
  int x ;
  int y ;
  int w ;
  int h ;
  CanvasRenderingContext2D contextTimeline;
  
  XChartsControlTimeline(this._timelineDataHandler, int position, int height, [this.seriesDataType = SERIES_DATA_MAX]) : super(position, -1, height) ;

  XChartsTimelineDataHandler get timelineDataHandler => this._timelineDataHandler ;
  
  bool get isDataLoaded => this._timelineDataHandler.isDataLoaded ;
  
  void disableHightlightBorder() {
    highlightLeftSelectionBorder = false ;
    highlightRightSelectionBorder = false ;
    drawHightlightBorder() ;
  }
  
  void defineHightlightBorder(int mouseX) {
    List<double> ret = _calcSeriesMinMaxValueX() ;
    
    if (ret == null) return ;
    
    double minValX = ret[0] ;
    double maxValX = ret[1] ;
    
    int timeRange = (maxValX - minValX).toInt() ;
    
    int selInit =  ( w * ( (this._timelineDataHandler.selectInitTime - minValX) / timeRange ) ).toInt() ;
    int selEnd =  ( w * ( (this._timelineDataHandler.selectEndTime - minValX) / timeRange ) ).toInt() ;
    
    int middle =  (selEnd - selInit)~/2;

    if (mouseX > (x + selInit + middle)) {
      highlightLeftSelectionBorder = false ;
      highlightRightSelectionBorder = true ;
    }
    else {
      highlightLeftSelectionBorder = true ;
      highlightRightSelectionBorder = false ;
    }
    
    drawHightlightBorder() ;
  }

  int _calcSeriesMinMaxValueX_dataChangeVersion = -1 ;
  double _calcSeriesMinMaxValueX_minValX ;
  double _calcSeriesMinMaxValueX_minValY ;
  double _calcSeriesMinMaxValueX_maxValX ;
  double _calcSeriesMinMaxValueX_maxValY ;
  
  List<double> _calcSeriesMinMaxValueX() {
    double minValX = null ;
    double minValY = null ;
    double maxValX = null ;
    double maxValY = null ;
    
    if ( _calcSeriesMinMaxValueX_dataChangeVersion == this.timelineDataHandler.dataChangeVersion ) {
      minValX = _calcSeriesMinMaxValueX_minValX ;
      minValY = _calcSeriesMinMaxValueX_minValY ;
      maxValX = _calcSeriesMinMaxValueX_maxValX ;
      maxValY = _calcSeriesMinMaxValueX_maxValY ;
    }
    else {
      List<XChartsData> allData = XCharts.getAllSeriesData(timelineDataHandler.selectSeries()) ;
      
      if (allData == null || allData.isEmpty) return null ;
      
      for (var d in allData) {
        if (maxValX == null || maxValX < d.valueX) maxValX = d.valueX.toDouble() ;
        if (minValX == null || minValX > d.valueX) minValX = d.valueX.toDouble() ;
        
        if (maxValY == null || maxValY < d.valueY) maxValY = d.valueY.toDouble() ;
        if (minValY == null || minValY > d.valueY) minValY = d.valueY.toDouble() ;
      }
      
      if (minValX > timelineDataHandler.initTime) minValX = timelineDataHandler.initTime.toDouble() ;
      if (maxValX < timelineDataHandler.endTime) maxValX = timelineDataHandler.endTime.toDouble() ;
      
      _calcSeriesMinMaxValueX_minValX = minValX ;
      _calcSeriesMinMaxValueX_minValY = minValY ;
      _calcSeriesMinMaxValueX_maxValX = maxValX ;
      _calcSeriesMinMaxValueX_maxValY = maxValY ;
      
      _calcSeriesMinMaxValueX_dataChangeVersion = this.timelineDataHandler.dataChangeVersion ;
    }
    
    return [minValX , maxValX, minValY , maxValY] ;
  }
  
  
  void drawHightlightBorder() {
    
    String color ;

    if ( seriesDataType == SERIES_DATA_MAX ) {
      color = colorMax ;  
    }
    else if ( seriesDataType == SERIES_DATA_MIN) {
      color = colorMin ;  
    }
    else if ( seriesDataType == SERIES_DATA_MEAN ) {
      color = colorMean ;  
    }
    else if ( seriesDataType == SERIES_DATA_MIN_MAX_MEAN ) {
      color = colorMean ;
    }

    List<double> ret = _calcSeriesMinMaxValueX() ;
    if (ret == null) return ;
    
    double minValX = ret[0] ;
    double maxValX = ret[1] ;
    
    int timeRange = (maxValX - minValX).toInt() ;
    
    int selInit =  ( w * ( (this._timelineDataHandler.selectInitTime - minValX) / timeRange ) ).toInt() ;
    int selEnd =  ( w * ( (this._timelineDataHandler.selectEndTime - minValX) / timeRange ) ).toInt() ;
    
    int middle =  (selEnd - selInit)~/2;

    contextTimeline.fillStyle = color ;
    contextTimeline.fillRect(x+selInit, y, 2, h) ;
    contextTimeline.fillRect(x+selInit+(selEnd-selInit)-2, y, 2, h);
    
    if ( highlightLeftSelectionBorder ) {
      contextTimeline.fillStyle = 'rgba(0,0,0, 0.10)' ;
    }
    else {
      contextTimeline.fillStyle = 'rgba(255,255,255, 0.60)' ;
    }
    
    contextTimeline.fillRect(x+selInit, y, 2, h) ;
    
    if ( highlightRightSelectionBorder ) {
      contextTimeline.fillStyle = 'rgba(0,0,0, 0.10)' ;
    }
    else {
      contextTimeline.fillStyle = 'rgba(255,255,255, 0.60)' ;
    }
    
    contextTimeline.fillRect(x+selInit+(selEnd-selInit)-2, y, 2, h);
    
  }
  
  List<XChartsDataSeries> getDataSeries(XCharts xcharts) {
    if (!isDataLoaded) return [] ;
    
    //timelineDataHandler.loadData() ;
    return timelineDataHandler.getSeries() ;
  }
  
  XChartsControlElementTimeline _controlElement ;
  
  int _prevDataChangeVersion = -1 ;
  CanvasElement _controlCanvas ;
  CanvasRenderingContext2D _controlCanvasContext ;
  int _controlCanvasW = -1 ;
  int _controlCanvasH = -1 ;

  @override
  List<XChartsElement> drawControl(XCharts xcharts, CanvasRenderingContext2D context, int chartWidth, int chartHeight) {
    
    int dataChangeVersion = timelineDataHandler.dataChangeVersion ;
    
    bool isSameDataVerion = dataChangeVersion == _prevDataChangeVersion ;
    
    _prevDataChangeVersion = dataChangeVersion ;
    
     x = 0 ;
     y = this.position == POSITION_NORTH ? 0 : chartHeight-height ;
     w = chartWidth ;
     h = height ;
     contextTimeline = context;
    
    double xAxisX = x+2.0 ;
    double xAxisY = y+h + 2.0 ;
    double xAxisW = w - 4.0 ;
    double xAxisH = h - 4.0 ;
    
    context.fillStyle = colorBackground ;
    context.fillRect(x,y , w,h) ;
    
    /////////////////////
    
    List<double> ret = _calcSeriesMinMaxValueX() ;
    if (ret == null) return null ;
    
    double minValX = ret[0] ;
    double maxValX = ret[1] ;
    double minValY = ret[2] ;
    double maxValY = ret[3] ;
    
    List<XChartsDataSeries> series = getDataSeries(xcharts) ;
    
    ///////////////////////
    
    String colorMax = XCharts.color2rgba(this.colorMax, colorAlpha) ;
    String colorMin = XCharts.color2rgba(this.colorMin, colorAlpha) ;
    String colorMean = XCharts.color2rgba(this.colorMean, colorAlpha) ;
    
    bool newCanvas = false ;
    if ( _controlCanvas == null || _controlCanvasW != w || _controlCanvasH != h ) {
      _controlCanvas = new CanvasElement() ;
      _controlCanvas.width = w ;
      _controlCanvas.height = h ;
      
      _controlCanvasContext = _controlCanvas.getContext('2d') ;
      
      _controlCanvasW = w ;
      _controlCanvasH = h ;
      newCanvas = true ;
    }
    
    if ( !isSameDataVerion || newCanvas ) {
      _controlCanvasContext.clearRect(0, 0, w,h) ;
      
      if ( seriesDataType == SERIES_DATA_MAX ) {
        _drawControlImplem(xcharts, _controlCanvasContext, 0, 0, w, h, minValX, maxValX, minValY, maxValY, XCharts.getAllSeriesDataMax(series) , colorMax) ;  
      }
      else if ( seriesDataType == SERIES_DATA_MIN) {
        _drawControlImplem(xcharts, _controlCanvasContext, 0, 0, w, h, minValX, maxValX, minValY, maxValY, XCharts.getAllSeriesDataMin(series) , colorMin) ;  
      }
      else if ( seriesDataType == SERIES_DATA_MEAN ) {
        _drawControlImplem(xcharts, _controlCanvasContext, 0, 0, w, h, minValX, maxValX, minValY, maxValY, XCharts.getAllSeriesDataMean(series) , colorMean) ;  
      }
      else if ( seriesDataType == SERIES_DATA_MIN_MAX_MEAN ) {
        _drawControlImplem(xcharts, _controlCanvasContext, 0, 0, w, h, minValX, maxValX, minValY, maxValY, XCharts.getAllSeriesDataMax(series) , colorMax) ;
        _drawControlImplem(xcharts, _controlCanvasContext, 0, 0, w, h, minValX, maxValX, minValY, maxValY, XCharts.getAllSeriesDataMin(series) , colorMin) ;
        _drawControlImplem(xcharts, _controlCanvasContext, 0, 0, w, h, minValX, maxValX, minValY, maxValY, XCharts.getAllSeriesDataMean(series) , colorMean , true) ;
      }
    }
    
    context.drawImage(_controlCanvas, x, y) ;
    
    int timeRange = (maxValX - minValX).toInt() ;
    
    int selInit =  ( w * ( (this._timelineDataHandler.selectInitTime - minValX) / timeRange ) ).toInt() ;
    int selEnd =  ( w * ( (this._timelineDataHandler.selectEndTime - minValX) / timeRange ) ).toInt() ;
    
    context.fillStyle = 'rgba(0,0,0 , 0.20)' ;
    context.fillRect(x+selInit,y , selEnd-selInit,h) ;
    
    drawHightlightBorder() ;
    
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
    
    _lastMovingSelectionFromLeftSide = null ;
    _setSelection(chart, x, y, false) ;
    _loadData() ;  
  }
  
  void _loadData() {
    this.control.timelineDataHandler.setAutoUpdateDataAndLoadData(true) ;
  }
  
  XChartsControlTimeline get control => this._control as XChartsControlTimeline ;

  @override
  void mouseEnter(XCharts chart, num x, num y) {
    
  }

  @override
  void mouseLeave(XCharts chart, num x, num y) {
    control.disableHightlightBorder(); 
  }
  
  @override
  void mouseMove(XCharts chart, num x, num y) {
    if (_pressed && chart._mousePressed) _setSelection(chart, x, y, true) ;
    
    control.defineHightlightBorder(x) ;
  }
  
  bool _lastMovingSelectionFromLeftSide = null ;
  
  void _setSelection(XCharts chart, num x, num y, bool moving) {
    double ratio = x / this._width ;
    
    if (ratio > 1) ratio = 1.0 ;
    else if (ratio < 0) ratio = 0.0 ;
    
    double diffInit = this.control.timelineDataHandler.selectInitTimeAsRatio - ratio ;
    double diffEnd = ratio - this.control.timelineDataHandler.selectEndTimeAsRatio ;
    
    if (diffInit < 0) diffInit = -diffInit ;
    if (diffEnd < 0) diffEnd = -diffEnd ;
    
    control.timelineDataHandler.setAutoUpdateData(false) ;
    
    bool leftSelection = null ;
    
    if (moving && _lastMovingSelectionFromLeftSide != null) {
      leftSelection = _lastMovingSelectionFromLeftSide ;
    }
    
    if (leftSelection == null) {
      leftSelection = diffInit < diffEnd ;
    }
    
    if ( leftSelection ) {
      this.control.timelineDataHandler.setSelectInitTimeByRatio(ratio) ;
      if (moving) _lastMovingSelectionFromLeftSide = true ;
    }
    else {
      this.control.timelineDataHandler.setSelectEndTimeByRatio(ratio) ;
      _lastMovingSelectionFromLeftSide = false ;
      if (moving) _lastMovingSelectionFromLeftSide = false ;
    }
    
    chart.requestRepaint() ;
  }
  
  bool _pressed = false ;
  
  @override
  void mousePress(XCharts chart, num x, num y) {
    print("press> $x ; $y") ;
    _pressed = true ;
    _lastMovingSelectionFromLeftSide = null ;
  }
  
  @override
  void mouseRelease(XCharts chart, num x, num y) {
    print("release> $x ; $y") ;
    _pressed = false ;
    _lastMovingSelectionFromLeftSide = null ;
    
    _loadData() ;
  }
  
}


