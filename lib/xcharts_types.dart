part of xcharts ;

abstract class XChartsType {
  
  int marginLeft = 0 ;
  int marginRight = 0 ;
  int marginTop = 0 ;
  int marginBottom = 0 ;
  
  void setMargin(int size) {
    marginLeft = marginRight = marginTop = marginBottom = size ;
  }

  void clearChart(XCharts chart, CanvasRenderingContext2D context) {
    if (chart.width != null && chart.height != null) {
      context.clearRect(0, 0, chart.width, chart.height) ;
    }
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
    
    int marginLeft = this.marginLeft+labelsYAxisAreaWidth ;
    int marginTop = this.marginTop ;
    int marginRight = this.marginRight ;
    int marginBottom = this.marginBottom+labelsXAxisAreaHeight ;
    
    Rectangle areaMargins = chart._getDrawMainAreaMargins() ;
    
    if (areaMargins != null) {
      marginLeft += areaMargins.left ;
      marginTop += areaMargins.top ;
      marginRight += areaMargins.width ;
      marginBottom += areaMargins.height ;
    }
    
    Point axisXinit = new Point(marginLeft+_axisXMarginLeft, h-marginBottom) ;
    Point axisXend = new Point(marginLeft+(w-(marginLeft+marginRight+_axisXMarginLeft+_axisXMarginRight)), h-marginBottom) ;
    
    Point axisYinit = new Point(marginLeft, h-marginBottom) ;
    Point axisYend = new Point(marginLeft, marginTop ) ;
    
    return [axisXinit, axisXend, axisYinit, axisYend] ;
  }
  
  int _axisXMarginLeft = 20 ;
  int _axisXMarginRight = 10 ;
  
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
    
    context.lineTo( axisXinit.x-_axisXMarginLeft , axisXinit.y ) ;
    context.lineTo( axisXend.x+_axisXMarginRight , axisXend.y ) ;
    
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
    num valsInit = values.isNotEmpty ? values.first : 0 ;
    num valsEnd = values.isNotEmpty ? values.last : 1 ;
    
    num valsRange = valsEnd - valsInit ;
    if (valsRange == 0) valsRange = 1.0 ;
    
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
    this._axisXMarginLeft = 0 ;
    this._axisXMarginRight = 10 ;
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
  
  bool skipConsecutiveSameYValue = true ;
  
  List _drawChartValues(XCharts chart, CanvasRenderingContext2D context) {
    int w = chart.width ;
    int h = chart.height ;
    
    List<Point> axisPoints = _getAxisPoints(chart) ;
    Point axisXinit = axisPoints[0] ;
    Point axisXend = axisPoints[1] ;
    Point axisYinit = axisPoints[2] ;
    Point axisYend = axisPoints[3] ;
    
    List<num> yVals = chart.getYValues() ;
    
    num yValsMin = yVals.isNotEmpty ? yVals.first : 0 ;
    num yValsMax = yVals.isNotEmpty ? yVals.last : 1 ;
    
    if (startScaleToZero) yValsMin = 0 ;
    
    num yValsRange = yValsMax - yValsMin ;
    
    int axixYheight = axisYinit.y - axisYend.y ;
    int axixXwidth = axisXend.x - axisXinit.x ;
    
    List<num> labelsVals = chart.getXValues() ;
    
    num xValMin = labelsVals.isNotEmpty ? labelsVals.first : 0 ;
    num xValMax = labelsVals.isNotEmpty ? labelsVals.last : 1 ;
        
    num xValRange = xValMax - xValMin ;
    
    ///////////////////
    
    var series = chart.series ;
    
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
        dataColor = chart.getColor( i ) ;
        s.color = dataColor;
      }
      
      List<Point> points = [] ;
      
      context.beginPath() ;
      
      int lastDataIdx = data.length-1 ;
      
      for (int j = 0 ; j < data.length ; j++) {
        var d = data[j] ;
        
        if (skipConsecutiveSameYValue && j > 0 && j < lastDataIdx) {
          var dPrev = data[j-1] ;
          var dNext = data[j+1] ;
        
          if ( d.y == dPrev.y && d.y == dNext.y ) {
            continue ;
          }
        }
        
        var vX = d.valueY ;
        var vY = d.valueX ;
        
        double valXRatio = (vX-yValsMin) / yValsRange ;
        double valYRatio = (vY-xValMin) / xValRange ;
        
        num valX = axisXinit.x + axixXwidth * valYRatio ;
        num valY = axisYend.y + axixYheight * (1-valXRatio) ;
        
        points.add( new Point(valX,valY) ) ;
        
        var elemDetail = new XChartsElementDetail(valX-valRadius , valY-valRadius , valDiamiter, valDiamiter,i, j,vX, vY, s.enabled);
        var elem = new XChartsElementHint(valX-valRadius , valY-valRadius , valDiamiter, valDiamiter, i, j, s, d, s.enabled) ;
        
        chartElements.add(elemDetail);
        chartElements.add(elem) ;
      }
      
      if(s.enabled){
       seriesPoints.add(points) ;
       seriesColors.add(dataColor) ;
      }
      
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


class XChartsTypeBar extends XChartsTypeWithXYAxis {
  
  XChartsTypeBar() {
    setMargin(15) ;
    _updateAxisMargin() ;
  }
  
  void _updateAxisMargin() {
    this._axisXMarginLeft = this._valuesBarWidth+this.labelYAxisMarkSize+1 ;
    this._axisXMarginRight = this._valuesBarWidth+1 ;
  }
  
  @override
  List<XChartsElement> drawChart(XCharts chart, CanvasRenderingContext2D context) {
    List ret = _drawChartValues(chart, context) ;
    
    super.drawChart(chart, context) ;
    
    if (ret == null) return [] ;
    
    List<List<Point>> seriesPoints = ret[0] ;
    List<String> seriesColors = ret[1] ;
    num xAxisX = ret[2] ;
    num xAxisY = ret[3] ;
    List<XChartsElement> chartElements = ret[4] ;
    
    return chartElements ;
  }
  
  int _valuesBarWidth = 10 ;
  
  int get valuesBarWidth => this._valuesBarWidth ;
  
  set valuesBarWidth(num n) {
    this._valuesBarWidth = n ;
    _updateAxisMargin() ;
  }
  
  int valuesBarBorder = 2 ;
  double valuesFillColorAlpha = 0.7 ;
  
  List _drawChartValues(XCharts chart, CanvasRenderingContext2D context) {
    int w = chart.width ;
    int h = chart.height ;
    
    List<Point> axisPoints = _getAxisPoints(chart) ;
    Point axisXinit = axisPoints[0] ;
    Point axisXend = axisPoints[1] ;
    Point axisYinit = axisPoints[2] ;
    Point axisYend = axisPoints[3] ;
    
    List<num> yVals = chart.getYValues() ;
    
    if (yVals.isEmpty) return null ;
    
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
    
    int valWidth = _valuesBarWidth ;
    if (valWidth < 2) valWidth = 2 ;
    
    int valWidthHalf = valWidth ~/ 2 ;
    
    int xAxisY = axisXinit.y ;
    
    for (int i = 0 ; i < series.length ; i++) {
      var s = series[i] ;
    
      var data = s.data ;
      var dataColor = s.color ;
    
      if (dataColor == null) {
        dataColor = chart.getColor(i) ;
        s.color = dataColor ;
      }
      
      List<Point> points = [] ;
      
      context.beginPath() ;
      
      for (int j = 0 ; j < data.length ; j++) {
        var d = data[j] ;
        
        var vX = d.valueX ;
        var vY = d.valueY ;
        
        double valXRatio = (vX-xValMin) / xValRange ;
        double valYRatio = (vY-yValsMin) / yValsRange ;
        
        num valX = axisXinit.x + axixXwidth * valXRatio ;
        num valY = axisYend.y + axixYheight * (1-valYRatio) ;
        
        points.add( new Point(valX,valY) ) ;
        
        num h = xAxisY - valY ;
        int hAdjust = 0 ;
        if (h < 3) {
          h = 3 ;
          hAdjust = 3 ;
        }
        
        var elemDetail = new XChartsElementDetail(valX-valWidthHalf, valY-hAdjust , valWidth, h,i, j,vX, vY, s.enabled);
        var elem = new XChartsElementHint(valX-valWidthHalf , valY-hAdjust , valWidth, h, i, j, s, d, s.enabled) ;
        
        chartElements.add(elemDetail);
        chartElements.add(elem) ;
      }
      
      seriesPoints.add(points) ;
      seriesColors.add(dataColor) ;
    }
    
    _drawChartValues_lines(seriesPoints, seriesColors, context, xAxisY);
   
    return [ seriesPoints , seriesColors , axisXinit.x , axisXinit.y , chartElements ] ;
  }

  void _drawChartValues_lines(List<List<Point>> seriesPoints, List<String> seriesColors, CanvasRenderingContext2D context, int xAxisY) {
    
    for (int i = 0 ; i < seriesPoints.length ; i++) {
      List<Point> points = seriesPoints[i] ;
      String dataColor = seriesColors[i] ;
      String dataColorAlpha = XCharts.color2rgba(dataColor, valuesFillColorAlpha) ;
      
      context.fillStyle = XCharts.color2rgba(dataColor, valuesFillColorAlpha) ;
      
      int valWidth = _valuesBarWidth ;
      if (valWidth < 2) valWidth = 2 ;
      
      int valWidthHalf = valWidth ~/ 2 ;
      
      context.strokeStyle = dataColor ;
      context.fillStyle = dataColorAlpha ;
      context.lineWidth = valuesBarBorder ;
      
      for (var p in points) {
        
        num h = xAxisY - p.y ;
        
        int hAdjust = 0 ;
        if (h < 3) {
          h = 3 ;
          hAdjust = 3 ;
        }
        
        context.beginPath() ;
        context.rect(p.x - valWidthHalf, p.y-hAdjust , _valuesBarWidth, h) ;
        context.fill() ;
        
        if (valuesBarBorder > 0) {
          context.beginPath() ;
          context.rect(p.x - valWidthHalf, p.y-hAdjust , _valuesBarWidth, h) ;
          context.stroke();
        }
        
      }
    
      
    }
  }
  

}


class XChartsTypeHeatMap extends XChartsType {
  
  CanvasImageSource backgroundImage ;
  num backgroundImageAlpha = 0.3 ;
  
  CanvasElement heatCanvas ;
  
  XChartsTypeHeatMap( [ this.backgroundImage ] ) {
    this.heatCanvas = new CanvasElement() ;
  }
  
  
  bool showIndividualData = false ;
  
  num heatAlphaMin = 0.30 ;
  num heatAlphaMax = 0.80 ;
  
  @override
  List<XChartsElement> drawChart(XCharts chart, CanvasRenderingContext2D context) {
    int w = chart.width ;
    int h = chart.height ;
    
    this.heatCanvas.width = w ;
    this.heatCanvas.height = h ;
    
    CanvasRenderingContext heatContext = this.heatCanvas.getContext('2d') ;
    
    if (backgroundImage != null) {
      num prevAlpha = context.globalAlpha ;
      context.globalAlpha = backgroundImageAlpha ;
      context.drawImage(backgroundImage, 0,0) ;  
      context.globalAlpha = prevAlpha ;
    }
  
    if (showIndividualData) {
      _drawMap(chart, context) ;
    }
    else {
      _drawMap(chart, heatContext) ;
      
      var prevGlobalAlpha = context.globalAlpha ;
      context.globalAlpha = heatAlphaMax ;
      context.drawImage(heatCanvas, 0,0) ;
      context.globalAlpha = prevGlobalAlpha ;
    }
    
    return null ;
  }
  
  num minDensityTolerance = 0.20 ;
  num maxDensityTolerance = 0.20 ;
  
  void _drawMap(XCharts chart, CanvasRenderingContext2D context) {
    Map<XChartsData,double> heatMap = _calcHeatMap(chart) ;
    
    List<double> densities = [] ;
    densities.addAll( heatMap.values ) ;
    densities.sort( (a,b) => a<b ? -1 : (a==b ? 0 : 1) ) ;
    
    double minDensity = densities.first ; 
    double maxDensity = densities.last ;
    
    if (minDensity == maxDensity) {
      minDensity-- ;
      if (minDensity < 0) minDensity = 0.0 ;
      maxDensity = minDensity+1.3 ;
    }
    
    double rangeDensity = maxDensity - minDensity ;
    
    if (minDensityTolerance > 0) {
      minDensity += minDensityTolerance * (rangeDensity * 0.45) ;
    }
    
    if (maxDensityTolerance > 0) {
      maxDensity -= maxDensityTolerance * (rangeDensity * 0.45) ;
    }
    
    if (minDensityTolerance > 0 || maxDensityTolerance > 0) {
      rangeDensity = maxDensity - minDensity ;  
    }
    
    List<XChartsData> orderedKeys = [] ;
    orderedKeys.addAll( heatMap.keys ) ;
    orderedKeys.sort( (d1,d2) {
      double dens1 = heatMap[d1] ;
      double dens2 = heatMap[d2] ;
      
      return dens1 < dens2 ? -1 : ( dens1 == dens2 ? 0 : 1) ;
    } ) ;
    
    num heatAlphaRange = heatAlphaMax - heatAlphaMin ;
    
    for (var data in orderedKeys) {
      double density = heatMap[data] ;

      double densityRatio = (density-minDensity) ;
      if (densityRatio < 0) densityRatio = 0.0 ;
      densityRatio /=  rangeDensity ;
      if (densityRatio > 1) densityRatio = 1.0 ; 
      
      int hue = ( (1-densityRatio) * 240).toInt() ;
      
      double heatAlpha ;
      if (showIndividualData) {
        heatAlpha = heatAlphaMin + (densityRatio * heatAlphaRange) ;
      }
      else {
        double ratio = heatAlphaMin/heatAlphaMax ;
        double range = 1-ratio ; 
        heatAlpha = ratio + (densityRatio * range) ;
      }
      
      context.fillStyle = 'hsla($hue, 100%, 50%, $heatAlpha)' ;
      
      var d = heatMap[data] ;
      context.beginPath() ;
      
      if ( data.width != null && data.height != null && data.width > 0 && data.height > 0 ) {
        if (!showIndividualData) {
          context.clearRect(data.x, data.y, data.width, data.height) ;
        }
        context.rect(data.x, data.y, data.width, data.height) ;  
      }
      else {
        num r ;
        
        if (data.width != null && data.width > 0) r = data.width ;
        else if (data.height != null && data.height > 0) r = data.height ;
        else r = heatSpreadSize ;
        
        if (r < 1) r = 1 ;
        
        context.arc(data.x, data.y, r, 0, 360) ;  
      }
      
      
      context.fill() ;
    }
    
  }
  
  num heatSpreadSize = 20 ;
  
  Map<XChartsData,double> _calcHeatMap(XCharts chart) {
    
    List<XChartsData> allData = XCharts.getAllSeriesData(chart.series) ;
    
    Map<XChartsData,double> densityMap = {} ;
    
    for (var data in allData) {
      double d = densityMap[data] ;
      densityMap[data] = d != null ? d+1 : 1.0 ;
    }
    
    Map<Point,double> spreadMap = {} ;
    
    for (var data in allData) {
      for (var data2 in densityMap.keys) {
        if ( data == data2 ) continue ;
        
        double dist = data.centerPoint.distanceTo(data2.centerPoint) ;
        
        double distRatio = 1 - (dist / heatSpreadSize) ;
        
        if (distRatio > 0 && distRatio <= 1) {
          double spread = heatSpreadSize * distRatio ; 
          var d = spreadMap[data2] ;
          spreadMap[data2] = d != null ? d+spread : spread ;
        }
      }
    }
    
    for (var p in spreadMap.keys) {
      var s = spreadMap[p] ;
      densityMap[p] += s ;
    }
   
    return densityMap ;
  }
  

}

