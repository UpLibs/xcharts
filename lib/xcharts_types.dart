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
  
  bool startScaleToZero = false ;
  
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
    
    
    //////////////////////////////////////////
    // horizontal labels:
    
    List<List> ret = chart.getLists_XLabelsAndXValues() ;
        
    List<String> xLabels = ret[0] ;
    List<num> xValues = ret[1] ;
    
    _drawAxisLabels(chart, context, xLabels, xValues, axisXinit, axisXend, true) ;
    

    //////////////////////////////////////////
    // vertical labels:
    
    List<List> ret2 = chart.getLists_YLabelsAndYValues() ;
        
    List<String> yLabels = ret2[0] ;
    List<num> yValues = ret2[1] ;
    
    _drawAxisLabels(chart, context, yLabels, yValues, axisYinit, axisYend, false) ;
    
  }
  
  void _drawAxisLabels(XCharts chart, CanvasRenderingContext2D context, List<String> labels, List<num> values, Point axisInit, Point axisEnd, bool horizontal) {
    num valsInit = values.first ;
    num valsEnd = values.last ;
    
    num valsRange = valsEnd - valsInit ;
    
    int axisSize = horizontal ? axisEnd.x - axisInit.x : axisInit.y - axisEnd.y ;
    
    num labelPos = horizontal ? axisInit.y+labelsFontSize+5 : axisInit.x-(labelsFontSize) ;
    
    num labelAxisMarkPointInit = horizontal ? axisInit.y-labelXAxisMarkSize : axisInit.x ;
    num labelAxisMarkPointEnd = horizontal ? axisInit.y : axisInit.x+labelYAxisMarkSize ;
    
    int lastAxisLabelEnd = null ;
    
    for (int i = 0; i < labels.length ; i++) {
      String label = labels[i] ;
      num val = values[i] ;
      
      TextMetrics textMetrics = context.measureText(label) ;
      
      double labelWidth = textMetrics.width ;
      
      double valRangeRatio = (val-valsInit) / valsRange ;
      
      int valInAxis = horizontal
          ? 
          axisInit.x + ( axisSize * valRangeRatio ).toInt()
          :
          axisInit.y - ( axisSize * valRangeRatio ).toInt()
          ;
      
      int labelPos1 = horizontal ? labelPos : labelPos - labelWidth.toInt() ;
      
      int labelPos2 = horizontal
          ?
          valInAxis - (labelWidth ~/ 2)
          :
          valInAxis + (labelsFontSize ~/ 2) -2
          ;
      
      if (horizontal) {
        if ( lastAxisLabelEnd != null && labelPos2 < lastAxisLabelEnd) continue ;  
      }
      else {
        if ( lastAxisLabelEnd != null && labelPos2 > lastAxisLabelEnd) continue ;
      }
      
      if (i > 0) {
        context.beginPath() ;
        
        if (horizontal) {
          context.lineTo( valInAxis , labelAxisMarkPointInit ) ;
          context.lineTo( valInAxis , labelAxisMarkPointEnd ) ;  
        }
        else {
          context.lineTo( labelAxisMarkPointInit , valInAxis ) ;
          context.lineTo( labelAxisMarkPointEnd , valInAxis ) ;
        }
        
        context.stroke() ;
      }
      
      if (horizontal) {
        context.fillText(label, labelPos2, labelPos1) ;
        lastAxisLabelEnd = labelPos2 + labelWidth.toInt() + 4 ;
      }
      else {
        context.fillText(label, labelPos1, labelPos2) ;
        lastAxisLabelEnd = labelPos2 - (labelsFontSize+10) ; 
      }
      
    }
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
    
    List<num> yVals = chart.getYValues() ;
    
    num yValsMin = yVals.first ;
    num yValsMax = yVals.last ;
    
    if (startScaleToZero) yValsMin = 0 ;
    
    num yValsRange = yValsMax - yValsMin ;
    
    int axixYheight = axisYinit.y - axisYend.y ;
    int axixXwidth = axisXend.x - axisXinit.x ;
    
    List<num> labelsVals = chart.getXValues() ;
    
    num xValMin = labelsVals.first ;
    num xValMax = labelsVals.last ;
        
    num xValRange = xValMax - xValMin ;
    
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
        
        var vX = d.valueY ;
        var vY = d.valueX ;
        
        double valXRatio = (vX-yValsMin) / yValsRange ;
        double valYRatio = (vY-xValMin) / xValRange ;
        
        num valX = axisXinit.x + axixXwidth * valYRatio ;
        num valY = axisYend.y + axixYheight * (1-valXRatio) ;
        
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


class XChartsTypeHeatMap extends XChartsType {
  
  CanvasImageSource backgroundImage ;
  num backgroundImageAlpha = 1.0 ;
  
  XChartsTypeHeatMap( [ this.backgroundImage ] ) {
    
  }
  
  
  @override
  List<XChartsElement> drawChart(XCharts chart, CanvasRenderingContext2D context) {
    int w = chart.width ;
    int h = chart.height ;
    
    if (backgroundImage != null) {
      num prevAlpha = context.globalAlpha ;
      context.globalAlpha = backgroundImageAlpha ;
      context.drawImage(backgroundImage, 0,0) ;  
      context.globalAlpha = prevAlpha ;
    }
    
    return null ;
  }

}

