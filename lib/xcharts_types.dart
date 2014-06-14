part of xcharts ;

abstract class XChartsType {
  
  int marginLeft = 0 ;
  int marginRight = 0 ;
  int marginTop = 0 ;
  int marginBottom = 0 ;
  
  void setMargin(int size) {
    marginLeft = marginRight = marginTop = marginBottom = size ;
  }
  
  List<XChartsElement> drawChart(XCharts chart, CanvasRenderingContext2D context) ;
  
}

abstract class XChartsTypeWithXYAxis extends XChartsType {
  
  @override
  List<XChartsElement> drawChart(XCharts chart, CanvasRenderingContext2D context) {
    
    _drawChartAxis(chart, context) ;
    _drawChartAxisLabels(chart, context) ;
    
    return null ;
  }

  int axisSize = 1 ;
  String axisColor = '#000000' ;
  
  List<Point> _getAxisPoints(XCharts chart) {
    int w = chart.width ;
    int h = chart.height ;
    
    int marginBottom = this.marginBottom+labelsXAxisAreaHeight ;
    int marginLeft = this.marginLeft+labelsYAxisAreaWidth ;
    
    Point axisXinit = new Point(marginLeft, h-marginBottom) ;
    Point axisXend = new Point(marginLeft+(w-(marginLeft+marginRight)), h-marginBottom) ;
    
    Point axisYinit = new Point(marginLeft, h-marginBottom) ;
    Point axisYend = new Point(marginLeft, marginTop ) ;
    
    return [axisXinit, axisXend, axisYinit, axisYend] ;
  }
  
  void _drawChartAxis(XCharts chart, CanvasRenderingContext2D context) {
    
    int w = chart.width ;
    int h = chart.height ;
    
    List<Point> axisPoints = _getAxisPoints(chart) ;
    Point axisXinit = axisPoints[0] ;
    Point axisXend = axisPoints[1] ;
    Point axisYinit = axisPoints[2] ;
    Point axisYend = axisPoints[3] ;
    
    context.strokeStyle = axisColor ;
    context.lineWidth = axisSize ;
        
    context.beginPath() ;
    
    context.lineTo( axisXinit.x , axisXinit.y ) ;
    context.lineTo( axisXend.x , axisXend.y ) ;
    
    context.stroke() ;
    
    context.beginPath() ;
    
    context.lineTo( axisYinit.x , axisYinit.y ) ;
    context.lineTo( axisYend.x , axisYend.y ) ;
    
    context.stroke() ;
    
  }
  
  int labelsYAxisAreaWidth = 20 ;
  int labelsXAxisAreaHeight = 15 ;
  String labelsColor = '#000000' ;
  
  int labelXAxisMarkSize = 7 ;
  int labelYAxisMarkSize = 7 ;
  
  String labelsFontFamily = 'Verdana' ;
  int labelsFontSize = 10 ;
  String labelsFontStyle = 'normal' ;
  
  bool startScalToZero = false ;
  
  void _drawChartAxisLabels(XCharts chart, CanvasRenderingContext2D context) {
    
    int w = chart.width ;
    int h = chart.height ;
    
    List<Point> axisPoints = _getAxisPoints(chart) ;
    Point axisXinit = axisPoints[0] ;
    Point axisXend = axisPoints[1] ;
    Point axisYinit = axisPoints[2] ;
    Point axisYend = axisPoints[3] ;
    
    
    context.font = '$labelsFontStyle ${labelsFontSize}px $labelsFontFamily' ;
    
    context.strokeStyle = axisColor ;
    context.lineWidth = axisSize ;
    context.fillStyle = labelsColor ;
    
    List<List> ret = chart.getLabelsNamesAndLabelsValues() ;
    
    List<String> labelsNames = ret[0] ;
    List<num> labelsVals = ret[1] ;
    
    //////////////////////////////////////////
    // horizontal labels:
    
    num valsInit = labelsVals.first ;
    num valsEnd = labelsVals.last ;
    
    num valsRange = valsEnd - valsInit ;
    
    int axixXwidth = axisXend.x - axisXinit.x ;
    
    num labelTextY = axisYinit.y+14 ;
    
    num labelXAxisMarkPointYInit = axisXinit.y-labelXAxisMarkSize ;
    num labelXAxisMarkPointYEnd = axisXinit.y ;
    
    int lastXAxisLabelEnd = -1000000000000 ;
    
    for (int i = 0; i < labelsNames.length ; i++) {
      String ln = labelsNames[i] ;
      num lv = labelsVals[i] ;
      
      TextMetrics textMetrics = context.measureText(ln) ;
      
      double lnWidth = textMetrics.width ;
      
      double valRangeRatio = (lv-valsInit) / valsRange ;
      
      int labelX = axisXinit.x + ( axixXwidth * valRangeRatio ).toInt() ;
      
      int labelXtext = labelX - (lnWidth ~/ 2) ;
      
      if (labelXtext < lastXAxisLabelEnd) continue ;
      
      if (i > 0) {
        context.beginPath() ;
        
        context.lineTo( labelX , labelXAxisMarkPointYInit ) ;
        context.lineTo( labelX , labelXAxisMarkPointYEnd ) ;
        
        context.stroke() ;
      }
      
      context.fillText(ln, labelXtext, labelTextY) ;
      
      lastXAxisLabelEnd = labelXtext + lnWidth.toInt() + 4 ;
    }
    
    //////////////////////////////////////////
    // vertical labels:
    
    List retYAxisScale = _getYAxisScale(chart) ;
    
    num yAxisMinVal = retYAxisScale[0] ;
    num yAxisMaxVal = retYAxisScale[1] ;
    List<num> yAxisVals = retYAxisScale[2] ;
    
    if (startScalToZero) yAxisMinVal = 0 ;
    
    num yAxisRangeVal = yAxisMaxVal - yAxisMinVal ;
    
    int axixYheight = axisYinit.y - axisYend.y ;
    
    num labelYAxisMarkPointXInit = axisYinit.x ;
    num labelYAxisMarkPointXEnd = axisXinit.x+labelYAxisMarkSize ;
    
    int lastLabelYAxisEnd = 1000000000000 ;
    
    for (int i = 0 ; i < yAxisVals.length ; i++) {
      var v = yAxisVals[i] ;
      String vs = v.toString() ;
      
      var metrics = context.measureText(vs) ;
      
      double vRange = (v-yAxisMinVal) / yAxisRangeVal ;
      
      num x = axisYinit.x - (metrics.width+4) ;
      num y = axisYend.y + ((1-vRange) * axixYheight) ;
      
      num textX = x - 3 ;
      num textY = y + (labelsFontSize ~/ 2) -1 ;
      
      if ( textY > lastLabelYAxisEnd ) continue ;
      
      context.fillText(vs, textX, textY) ;
      
      if (i < yAxisVals.length-1) {
        context.beginPath() ;
        
        context.lineTo( labelYAxisMarkPointXInit , y ) ;
        context.lineTo( labelYAxisMarkPointXEnd , y ) ;
        
        context.stroke() ;
      }
      
      lastLabelYAxisEnd = (textY-20).toInt() ;
    }
    
  }
  
  List _getYAxisScale(XCharts chart) {
    var series = chart._series ;
    
    num minVal = null ;
    num maxVal = null ;
    
    Map<num,num> valsMap = {} ;
    
    for (var s in series) {
      var data = s.data ;
      
      for (var d in data) {
        var v = d.value ;
        
        if (minVal == null || v < minVal) minVal = v ;
        if (maxVal == null || v > maxVal) maxVal = v ;
        
        valsMap[v] = v ;
      }
    }
    
    List<num> vals = [] ;

    for (var v in valsMap.values) {
      vals.add(v) ;
    }
    
    vals.sort((a,b) => a < b ? -1 : (a == b ? 0 : 1) ) ;
    
    return [ minVal , maxVal , vals ] ;
  }
 
}

class XChartsTypeDot extends XChartsTypeLine {
  
  XChartsTypeDot() : super() {
    this.valuesFill = false ;
    this.valuesShowLines = false ;
  }
  
}

class XChartsTypeLine extends XChartsTypeWithXYAxis {
  
  XChartsTypeLine() {
    setMargin(15) ;
  }
  
  @override
  List<XChartsElement> drawChart(XCharts chart, CanvasRenderingContext2D context) {
    List ret = _drawChartValues(chart, context) ;
    
    super.drawChart(chart, context) ;
    
    List<List<Point>> seriesPoints = ret[0] ;
    List<String> seriesColors = ret[1] ;
    num xAxisX = ret[2] ;
    num xAxisY = ret[3] ;
    List<XChartsElement> chartElements = ret[4] ;
    
    _drawChartValues_dots(seriesPoints, seriesColors, context, true, xAxisX, xAxisY) ;
    
    return chartElements ;
  }
  
  int valuesDotRadius = 4 ;
  int valuesLineSize = 2 ;
  double valuesFillColorAlpha = 0.7 ;
  bool valuesFill = true ;
  bool valuesShowLines = true ;
  
  List _drawChartValues(XCharts chart, CanvasRenderingContext2D context) {
    int w = chart.width ;
    int h = chart.height ;
    
    List<Point> axisPoints = _getAxisPoints(chart) ;
    Point axisXinit = axisPoints[0] ;
    Point axisXend = axisPoints[1] ;
    Point axisYinit = axisPoints[2] ;
    Point axisYend = axisPoints[3] ;
    
    List ret = _getYAxisScale(chart) ;
    
    num minVal = ret[0] ;
    num maxVal = ret[1] ;
    
    if (startScalToZero) minVal = 0 ;
    
    num rangeVal = maxVal - minVal ;
    
    int axixYheight = axisYinit.y - axisYend.y ;
    int axixXwidth = axisXend.x - axisXinit.x ;
    
    List<num> labelsVals = chart.getLabelsValues() ;
    
    num labelValInit = labelsVals.first ;
    num labelValEnd = labelsVals.last ;
        
    num labelValRange = labelValEnd - labelValInit ;
    
    ///////////////////
    
    var series = chart._series ;
    
    List<List<Point>> seriesPoints = [] ;
    List<String> seriesColors = [] ;
    
    List<XChartsElement> chartElements = [] ;
    
    int valRadius = valuesDotRadius > 0 ? valuesDotRadius+1 : 2 ;
    int valDiamiter = valRadius * 2 ;
    
    for (int i = 0 ; i < series.length ; i++) {
      var s = series[i] ;
    
      var data = s.data ;
      var dataColor = s.color ;
    
      if (dataColor == null) {
        dataColor = chart.defaultColors[ i % chart.defaultColors.length ] ;
      }
      
      List<Point> points = [] ;
      
      context.beginPath() ;
      
      for (int j = 0 ; j < data.length ; j++) {
        var d = data[j] ;
        
        var v = d.value ;
        var lv = d.labelValue ;
        
        double valRatio = (v-minVal) / rangeVal ;
        double labelValRatio = (lv-labelValInit) / labelValRange ;
        
        num valX = axisXinit.x + axixXwidth * labelValRatio ;
        num valY = axisYend.y + axixYheight * (1-valRatio) ;
        
        points.add( new Point(valX,valY) ) ;
        
        var elem = new XChartsElement(valX-valRadius , valY-valRadius , valDiamiter, valDiamiter, i, j, s, d) ;
        
        chartElements.add(elem) ;
      }
      
      seriesPoints.add(points) ;
      seriesColors.add(dataColor) ;
    }
    
    _drawChartValues_lines(seriesPoints, seriesColors, context, axisXinit.y);
   
    return [ seriesPoints , seriesColors , axisXinit.x , axisXinit.y , chartElements ] ;
  }

  void _drawChartValues_lines(List<List<Point>> seriesPoints, List<String> seriesColors, CanvasRenderingContext2D context, int xAxisY) {
    
    for (int i = 0 ; i < seriesPoints.length ; i++) {
      List<Point> points = seriesPoints[i] ;
      String dataColor = seriesColors[i] ;
      // fill:
      
      context.fillStyle = XCharts.color2rgba(dataColor, valuesFillColorAlpha) ;
      
      if (valuesFill) {
        context.beginPath() ;
        for (var p in points) {
          context.lineTo(p.x, p.y) ;
        }
        
        context.lineTo(points.last.x, xAxisY) ;
        context.lineTo(points.first.x, xAxisY) ;
        
        context.fill() ;
      }
      
      // lines:
      
      if (valuesShowLines) {
        context.strokeStyle = dataColor ;
        context.lineWidth = valuesLineSize ;
        
        context.beginPath() ;
        for (var p in points) {
          context.lineTo(p.x, p.y) ;
        }
        context.stroke() ;
      
        context.stroke() ;
      }
      
      // dots:
      
      if ( valuesDotRadius > 0 ) {
        context.fillStyle = dataColor ;
        
        for (var p in points) {
          context.beginPath() ;
          context.arc(p.x, p.y, valuesDotRadius, 0, 360) ;
          context.fill() ;
        }
      }
      
    }
  }
  

  void _drawChartValues_dots(List<List<Point>> seriesPoints, List<String> seriesColors, CanvasRenderingContext2D context, bool onlyBorderDots , num xAxisX, num xAxixY ) {
    if (valuesDotRadius <= 0) return ;
    
    for (int i = 0 ; i < seriesPoints.length ; i++) {
      List<Point> points = seriesPoints[i] ;
      String dataColor = seriesColors[i] ;
      
      // dots:
      context.fillStyle = dataColor ;
      
      for (var p in points) {
        context.beginPath() ;
        
        if (!onlyBorderDots || (p.x == xAxisX || p.y == xAxixY) ) {
          context.arc(p.x, p.y, valuesDotRadius, 0, 360) ;
          context.fill() ;
        }
      }
      
    }
    
  }
  
}
