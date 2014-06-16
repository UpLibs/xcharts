library xcharts;

import 'dart:html';
import 'dart:async';

part './xcharts_types.dart' ;

class XChartsDataSeries {
  
  String name ;
  List<XChartsData> data ;
  String color ;
  
  XChartsDataSeries( this.name , this.data , [ this.color ]) ;
  
  List<String> getXLabels() {
    List<String> labels = [] ;
    
    for (var d in data) {
      labels.add( d.labelX ) ;
    }
    
    return labels ;
  }
  
  List<String> getYLabels() {
    List<String> labels = [] ;
    
    for (var d in data) {
      labels.add( d.labelY ) ;
    }
    
    return labels ;
  }

  List<num> getXValues() {
    List<num> vals = [] ;
    
    for (var d in data) {
      vals.add( d.valueX ) ;
    }
    
    return vals ;
  }

  List<num> getYValues() {
    List<num> vals = [] ;
    
    for (var d in data) {
      vals.add( d.valueY ) ;
    }
    
    return vals ;
  }
  
  List<Point> getXYValues() {
    List<Point> vals = [] ;
    
    for (var d in data) {
      vals.add( new Point( d.valueX , d.valueY ) ) ;
    }
    
    return vals ;
  }

  
}

class XChartsData {
  
  num valueY ;
  num valueX ;
  String _labelX ;
  String _labelY ;
  String hint ;
  
  String get labelX => _labelX != null ? _labelX : valueX.toString() ;
  String get labelY => _labelY != null ? _labelY : valueY.toString() ;
  
  XChartsData( this.valueX , this.valueY , [this._labelX , this._labelY , this.hint]) ;
  
  int width ;
  int height ;
  
  num get x => valueX ;
  num get y => valueY ;

  Point get point => new Point(x,y) ;
  Point get centerPoint => new Point(x + (width != null ? width/2 : 0) , y + (height != null ? height/2 : 0) ) ;

  @override
  String toString() {
    return "$x [$labelX] , $y [$labelY] ; $width x $height <$hint>" ;
  }
  
}

class XCharts {
  

  static String color2rgba(String color, double alpha) {
    color = color.trim().toLowerCase() ;
    
    int r ;
    int g ;
    int b ;
    
    if (color.startsWith('rgb')) {
      color = color.replaceFirst(new RegExp(r'^rgba?\s*\('), '') ;
      color = color.replaceFirst(new RegExp(r'\)\s*$'), '') ;
      
      List<String> params = color.split(new RegExp(r'\s*,\s*')) ;
      
      r = int.parse(params[0]) ;
      g = int.parse(params[1]) ;
      b = int.parse(params[2]) ;
    }
    else if (color.startsWith('#')) {
      color = color.substring(1) ;
      
      if (color.length == 1) {
        r=g=b = int.parse(color+color, radix: 16) ;
      }
      else if (color.length == 3) {
        String sr = color.substring(0,1) ;
        String sg = color.substring(1,2) ;
        String sb = color.substring(2,3) ;
        
        r = int.parse(sr+sr , radix: 16) ;
        g = int.parse(sg+sg , radix: 16) ;
        b = int.parse(sb+sb , radix: 16) ;
      }
      else if (color.length == 6) {
        r = int.parse(color.substring(0,2) , radix: 16) ;
        g = int.parse(color.substring(2,4) , radix: 16) ;
        b = int.parse(color.substring(4,6) , radix: 16) ;
      }
    }
    else {
      return color ;
    }
    
    if (alpha == 1) {
      return 'rgb($r,$g,$b)' ;
    }
    
    return 'rgba($r,$g,$b,$alpha)' ;
  }
  

  List<String> defaultColors = [
  "#376085" ,
  "#68d4e6" ,
  "#ffbc41" ,
  "#d54052" ,
  "rgb(119, 170, 84)",
  "rgb(112, 113, 200)",
  "rgb(197, 143, 186)",
  "rgb(181, 185, 198)"
  ];

  
  //////////////////////////////////////////////////////////////////////
  

  XChartsType _type ;
  CanvasElement _canvas ;
  CanvasRenderingContext2D _context ;
  
  XCharts( this._type ) {
    this._canvas = new CanvasElement() ;
    this._context = _canvas.getContext('2d') ;
  }
  
  XChartsType get type => _type ;
  
  /////////////////////////////////////////////////////////////////////////////////////
  
  List<XChartsDataSeries> _series = [] ;
  
  void addSeries(XChartsDataSeries serie) => _series.add(serie) ;
  bool removeSeries(XChartsDataSeries serie) => _series.remove(serie) ;
  bool containsSeries(XChartsDataSeries serie) => _series.contains(serie) ;
  
  /////////////////////////////////////////////////////////////////////////////////////
  
  List<String> getXLabels() => getLists_XLabelsAndXValues()[0] ;
  List<String> getYLabels() => getLists_YLabelsAndYValues()[0] ;
  
  List<List> getLists_XLabelsAndXValues() {
    Map<num,String> valuesAndLabels = getXValuesAndLabels() ;
    
    List<num> vals = _getValues(valuesAndLabels) ;
    
    List<String> labels = [] ;
    
    for (int i = 0 ; i < vals.length ; i++) {
      num v = vals[i] ;
      String s = valuesAndLabels[v] ;
      labels.add(s) ;
    }
    
    return [ labels , vals ] ;
  }
  
  List<List> getLists_YLabelsAndYValues() {
      Map<num,String> valuesAndLabels = getYValuesAndLabels() ;
      
      List<num> vals = _getValues(valuesAndLabels) ;
      
      List<String> labels = [] ;
      
      for (int i = 0 ; i < vals.length ; i++) {
        num v = vals[i] ;
        String s = valuesAndLabels[v] ;
        labels.add(s) ;
      }
      
      return [ labels , vals ] ;
    }
  
  List<num> getXValues() => _getValues( getXValuesAndLabels() ) ;
  List<num> getYValues() => _getValues( getYValuesAndLabels() ) ;
  
  List<num> _getValues(Map<num,String> map) {
    List<num> vals = [] ;
    
    for ( var v in map.keys ) {
      vals.add(v) ;
    }
    
    vals.sort( (n1,n2) => n1<n2 ? -1 : (n1==n2 ? 0 : 1) ) ;
    
    return vals ;
  }
  
  Map<num,String> getXValuesAndLabels() {
    Map<num,String> map = {} ;
    
    for (var s in _series) {
      List<String> labels = s.getXLabels() ;
      List<num> values = s.getXValues() ;
      
      for (int i = 0 ; i < labels.length ; i++) {
        var l = labels[i] ;
        var v = values[i] ;
        
        map[v] = l ;
      }
    }
   
    return map ;
  }
  
  Map<num,String> getYValuesAndLabels() {
    Map<num,String> map = {} ;
    
    for (var s in _series) {
      List<String> labels = s.getYLabels() ;
      List<num> values = s.getYValues() ;
      
      for (int i = 0 ; i < labels.length ; i++) {
        var l = labels[i] ;
        var v = values[i] ;
        
        map[v] = l ;
      }
    }
   
    return map ;
  }
  
  List<Point> getXYValues() {
    List<Point> vals = [] ;
    
    for (var s in _series) {
      vals.addAll( s.getXYValues() ) ;
    }
    
    vals.sort( (p1,p2) {
      if ( p1.x < p2.x ) {
        return -1 ;
      }
      else if ( p1.x == p2.x ) {
        return p1.y < p2.y ? -1 : ( p1.y == p2.y ? 0 : 1 ) ;
      }
      else {
        return 1 ;
      }
    } ) ;
   
    return vals ;
  }
  
  List<XChartsData> getAllSeriesData() {
    List<XChartsData> vals = [] ;
        
    for (var s in _series) {
      vals.addAll( s.data ) ;
    }
    
    vals.sort( (d1,d2) {
      if ( d1.x < d2.x ) {
        return -1 ;
      }
      else if ( d1.x == d2.x ) {
        return d1.y < d2.y ? -1 : ( d1.y == d2.y ? 0 : 1 ) ;
      }
      else {
        return 1 ;
      }
    } ) ;
    
    return vals ;
  }
  
  /////////////////////////////////////////////////////////////////////////////////////
  
  Element _parent ;
  
  int _width ;
  int _height ;
  
  int get width => _width ;
  int get height => _height ;
  
  StreamSubscription<MouseEvent> _onMouseMoveSubscription ;
  StreamSubscription<MouseEvent> _onMouseClickSubscription ;
  StreamSubscription<MouseEvent> _onWindowResizeSubscription ;
  
  void _checkCanvasAtached(Element parent) {
    if ( identical( this._parent , parent ) ) return ;
    
    if ( this._parent != null ) {
      _canvas.remove() ;
    }
    
    this._parent = parent ;
    
    if ( !parent.children.contains(_canvas) ) {
      parent.children.add(_canvas) ;
    }
    
    if ( _onMouseMoveSubscription != null ) _onMouseMoveSubscription.cancel() ;
    if ( _onMouseClickSubscription != null ) _onMouseClickSubscription.cancel() ;
    if ( _onWindowResizeSubscription != null ) _onWindowResizeSubscription.cancel() ;
    
    _onMouseMoveSubscription = _canvas.onMouseMove.listen( _processMouseMove ) ;
    _onMouseClickSubscription = _canvas.onClick.listen( _processMouseClick ) ;
    
    _updateSize() ;
    
    _onWindowResizeSubscription = window.onResize.listen( (e) => repaint() ) ;
    
  }
  
  void _processMouseMove(MouseEvent e) {
    if (_chartElements == null) return ;
    
    num x = e.offset.x ;
    num y = e.offset.y ;

    _hintElements.clear() ;
    
    for (XChartsElement e in _chartElements) {
      if ( e.containsPoint(x, y) ) {
        _hintElements.add(e) ;
        
        _OnMouseOverChartElement(e) ;
      }
    }
    
    _showHints() ;
    
  }
  void _processMouseClick(MouseEvent e) {
    if (_chartElements == null) return ;
    
    num x = e.offset.x ;
    num y = e.offset.y ;

    for (var e in _chartElements) {
      if ( e.containsPoint(x, y) ) {
        _OnMouseClickChartElement(e) ;
      }
    }
  }
  
  void _OnMouseOverChartElement(XChartsElement elem) {
    
  }
  
  
  void _OnMouseClickChartElement(XChartsElement elem) {
      
  }

  void _updateSize() {

    int width = _parent.offsetWidth ;
    int height = _parent.offsetHeight ;
    
    this._width = width ;
    this._height = height ;
    
    _canvas.width = width ;
    _canvas.height = height ;
    
    //High pixel density displays - multiply the size of the canvas height/width by the device pixel ratio, then scale.
    if (window.devicePixelRatio != null) {
      _canvas.style.width = "${width}px";
      _canvas.style.height = "${height}px";
      _canvas.height = (height * window.devicePixelRatio).round();
      _canvas.width = (width * window.devicePixelRatio).round();
      _context.scale(window.devicePixelRatio, window.devicePixelRatio);
    }
    
  }
  
  void showAt(Element parent) {
    _checkCanvasAtached(parent) ;
    
    repaint() ;
  }
  
  List<XChartsElement> _chartElements ;
  
  void repaint() {
    
    _chartElements = _type.drawChart(this, _context) ;
    
  }
  
  ////////////////////////////////////////////////////////////////////////////////
  
  List<XChartsElement> _hintElements = [] ;
  
  Map<XChartsElement, Element> _currentHintElements = {} ;
  
  void _showHints() {
    
    Iterable<XChartsElement> elemsIter = _hintElements.where((e) => e.containsHint()) ;
    
    Map<XChartsElement, Element> hintsMap = {} ;
    
    for (var e in elemsIter) {
      var prevHint = _currentHintElements[e] ;
      if (prevHint == null) {
        _currentHintElements[e] = prevHint = _createHint(e) ;
      }
      hintsMap[e] = prevHint ;
    }
    
    List<XChartsElement> del = [] ;
    
    for (var e in _currentHintElements.keys) {
      if ( !hintsMap.containsKey(e) ) {
        del.add(e) ;
      }
    }
    
    for (var e in del) {
      var prevHint = _currentHintElements.remove(e) ;
      prevHint.remove() ;
    }
    
  }
  
  Element _createHint(XChartsElement chartElem) {

    int parentLeft = (chartElem.x.toInt() + chartElem.width.toInt() + 3).toInt() ;
    int parentTop = chartElem.y.toInt() - 5 ;
    
    Element elem = new DivElement() ;
    elem.style.position = 'absolute' ;
    elem.style.left = "${parentLeft}px";
    elem.style.top = "${parentTop}px";
    elem.style.backgroundColor = 'rgba(255,255,255 , 0.8)' ;
    elem.style.border = '1px solid rgba(0,0,0, 0.8)' ;
    elem.text = chartElem.hint ;
    
    this._parent.children.add(elem) ;
    
    return elem ;
  }
  
}

class XChartsElement {
  
  num x ;
  num y ;
  num width ;
  num height ;
  
  int seriesIndex ;
  int valueIndex ;

  XChartsDataSeries series ;
  XChartsData data ;
  
  XChartsElement( this.x , this.y , this.width , this.height , this.seriesIndex , this.valueIndex , this.series , this.data ) ;
  
  operator == (XChartsElement o) {
    return this.x == o.x
        && this.y == o.y
        && this.width == o.width
        && this.seriesIndex == o.seriesIndex
        && this.valueIndex == o.valueIndex ;
  }
  
  int get hashCode {
    int result = 1;
    result = 31 * result + x.toInt() ;
    result = 31 * result + y.toInt() ;
    result = 31 * result + width.toInt() ;
    result = 31 * result + height.toInt() ;
    result = 31 * result + seriesIndex ;
    result = 31 * result + valueIndex ;
    return result;
 }
  
  bool containsPoint(int x , int y) {
    return x > this.x && x <= this.x+this.width && y > this.y && y <= this.y+this.height ;
  }
  
  String get hint => data.hint ;
  
  bool containsHint() {
    return data.hint != null ;
  }
  
  
  
}


