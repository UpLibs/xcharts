library xcharts;

import 'dart:html';
import 'dart:async';
import 'dart:math' as Math ;

import 'package:numerical_collection/numerical_collection.dart';

part './xcharts_types.dart' ;
part './xcharts_timeline.dart' ;
part './xcharts_control.dart' ;

class XChartsDataSeries {
  
  String name ;
  List<XChartsData> data ;
  String color ;
  
  bool enabled ;
  
  XChartsDataSeries( this.name , this.data , [ this.color , this.enabled = true ]) {
    sortData() ;  
  }
  
  XChartsDataSeries clone(){
    XChartsDataSeries clone = new XChartsDataSeries(this.name, this.data);
    clone.color = this.color;
    clone.enabled = this.enabled;
    
    return clone;
  }
  
  void sortData() {
    this.data.sort( (a,b) => a.valueX.compareTo(b.valueX) ) ;
  }
  
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

  Map<String, dynamic> _props = {} ;
  
  Map<String, dynamic> get properties => _props ;
  
  NumericalList asNumericalListXValues() {
    return new NumericalList.fromList( getXValues() ) ;
  }
  
  NumericalList asNumericalListYValues() {
    return new NumericalList.fromList( getYValues() ) ;
  }

}

class XChartsData {
  
  num valueY ;
  num valueX ;
  String _labelX ;
  String _labelY ;
  String hint ;
  int _hintHeight ;
  
  String get labelX => _labelX != null ? _labelX : valueX.toString() ;
  String get labelY => _labelY != null ? _labelY : valueY.toString() ;
  
  void set labelY(String label) {
      this._labelY = label;           
  }
  
  void set labelX(String label) {
      this._labelX = label;           
  }
     
  XChartsData( this.valueX , this.valueY , [this._labelX , this._labelY , this.hint, this._hintHeight]) ;
  
  XChartsData clone() {
    var clone = new XChartsData( this.valueX , this.valueY, this._labelX , this._labelY , this.hint , this._hintHeight ) ;
    clone.width = this.width ;
    clone.height = this.height ;
    
    return clone ;
  }
  
  static const int DEFAULT_HINT_HEIGHT = 24 ;
  static const int MIN_HINT_HEIGHT = 2 ;
  
  int get hintHeight => _hintHeight == null ? DEFAULT_HINT_HEIGHT : _hintHeight ;
  
  set hintHeight(int height) => _hintHeight = height >= MIN_HINT_HEIGHT ? height : MIN_HINT_HEIGHT ;
  
  int width ;
  int height ;
  
  num get x => valueX ;
  num get y => valueY ;
  
  operator == (XChartsData o) {
    return super==(o)
        && this.valueY == o.valueY
        && this.valueX == o.valueX ;
  }

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
  

  List<String> _defaultColors = [
  "#376085" ,
  "#68d4e6" ,
  "#ffbc41" ,
  "#d54052" ,
  "rgb(119, 170, 84)",
  "rgb(112, 113, 200)",
  "rgb(197, 143, 186)",
  "rgb(181, 185, 198)"
  ];

  List<String> get defaultColors => new List.from( _defaultColors ) ;
  
  set defaultColors(List<String> colors) => _defaultColors = new List.from(colors) ;
  
  String getColor(int serieIndex) {
    return _defaultColors[ serieIndex % _defaultColors.length ] ;
  }
  
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
  
  List<XChartsDataSeries> _allSeries = [] ;
  
  List<XChartsDataSeries> get _series => new List.from( this._allSeries.where( (s) => s.enabled ) ) ;
  
  List<XChartsDataSeries> get series => new List.from( this._allSeries ) ;
  List<XChartsDataSeries> get seriesEnabled => new List.from( this._allSeries.where( (s) => s.enabled ) ) ;
  
  void clearSeries() => _allSeries.clear() ;
  
  void setSeries( List<XChartsDataSeries> series) {
    _allSeries.clear() ;
    _allSeries.addAll(series) ;
    
    requestRepaint() ;
  }
  
  void addSerie(XChartsDataSeries serie) => _allSeries.add(serie) ;
  bool removeSerie(XChartsDataSeries serie) => _allSeries.remove(serie) ;
  bool containsSerie(XChartsDataSeries serie) => _allSeries.contains(serie) ;
  
  XChartsDataSeries getSerie(String serieName) {
    for ( var serie in _allSeries ) {
      if (serie.name == serieName) return serie ;
    }
    return null ;
  }
  
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
  
  static List<XChartsData> getAllSeriesData(List<XChartsDataSeries> series) {
    List<XChartsData> vals = [] ;
        
    for (var s in series) {
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
  StreamSubscription<MouseEvent> _onMousePressSubscription ;
  StreamSubscription<MouseEvent> _onMouseReleaseSubscription ;
  StreamSubscription<MouseEvent> _onParentResizeSubscription ;
  StreamSubscription<MouseEvent> _onWindowResizeSubscription ;
  
  bool get isAttached => this._parent != null ;
  
  void _checkCanvasAttached(Element parent) {
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
    if ( _onMousePressSubscription != null ) _onMousePressSubscription.cancel() ;
    if ( _onMouseReleaseSubscription != null ) _onMouseReleaseSubscription.cancel() ;
    if ( _onParentResizeSubscription != null ) _onParentResizeSubscription.cancel() ;
    if ( _onWindowResizeSubscription != null ) _onWindowResizeSubscription.cancel() ;
    
    _onMouseMoveSubscription = _canvas.onMouseMove.listen( _processMouseMove ) ;
    _onMouseClickSubscription = _canvas.onClick.listen( _processMouseClick ) ;
    _onMousePressSubscription = _canvas.onMouseDown.listen( _processMousePress ) ;
    _onMouseReleaseSubscription = _canvas.onMouseUp.listen( _processMouseRelease ) ;
    
    _onParentResizeSubscription = _parent.onResize.listen( (e) => _updateSize() ) ;
    _onWindowResizeSubscription = window.onResize.listen( (e) => _updateSize() ) ;
    
    _updateSize() ;
    
  }
  
  void _processMouseMove(MouseEvent e) {
    if (_chartElements == null) return ;
    
    num x = e.offset.x ;
    num y = e.offset.y ;
    
    _processMouseMoveHints(e,x,y) ;
    
    _processMouseMoveControls(e, x, y) ;
    
    for (XChartsElement e in _chartElements) {
      if ( e.containsPoint(x, y) ) {
        _OnMouseOverChartElement(e) ;
      }
    }
    
    _checkNeedRepaint() ;
  }
  
  bool _mousePressed = false ;
  
  void _processMousePress(MouseEvent e) {
    _mousePressed = true ;
    
    if (_chartElements == null) return ;
    
    num x = e.offset.x ;
    num y = e.offset.y ;
    
    _processMousePressControls(e, x, y) ;
    
    _checkNeedRepaint() ;
  }

  void _processMouseRelease(MouseEvent e) {
    _mousePressed = false ;
    
    if (_chartElements == null) return ;
    
    num x = e.offset.x ;
    num y = e.offset.y ;
    
    _processMouseReleaseControls(e, x, y) ;
    
    _checkNeedRepaint() ;
  }

  
  void _processMouseMoveControls(MouseEvent e, num x, num y) {
    for (XChartsElement e in _chartElements) {
      if ( e is XChartsControlElement && e.containsPoint(x, y) ) {
        e.mouseMove(this, x - e._x , y - e._y ) ;
      }
    }
  }

  void _processMouseClickControls(MouseEvent e, num x, num y) {
    for (XChartsElement e in _chartElements) {
      if ( e is XChartsControlElement && e.containsPoint(x, y) ) {
        e.mouseClick(this, x - e._x , y - e._y ) ;
      }
    }
  }
  
  void _processMousePressControls(MouseEvent e, num x, num y) {
    for (XChartsElement e in _chartElements) {
      if ( e is XChartsControlElement && e.containsPoint(x, y) ) {
        e.mousePress(this, x - e._x , y - e._y ) ;
      }
    }
  }

  void _processMouseReleaseControls(MouseEvent e, num x, num y) {
    for (XChartsElement e in _chartElements) {
      if ( e is XChartsControlElement && e.containsPoint(x, y) ) {
        e.mouseRelease(this, x - e._x , y - e._y ) ;
      }
    }
  }
  
  void _processMouseMoveHints(MouseEvent e, num x, num y) {
    _hintElements.clear() ;
        
    for (XChartsElement e in _chartElements) {
      if ( e is XChartsElementHint && e.containsPoint(x, y) && e._enabled ) {
        _hintElements.add(e) ;
      }
    }
    
    _showHints() ;
  }
  
  void _processMouseClick(MouseEvent e) {
    if (_chartElements == null) return ;
    
    num x = e.offset.x ;
    num y = e.offset.y ;
    
    _processMouseClickControls(e, x, y) ;

    List elementsMouseClicks = new List();
    for (var e in _chartElements) {
      if ( e.containsPoint(x, y) && e is XChartsElementDetail && e._enabled ) {
        elementsMouseClicks.add(e);
      }
    }
    
    if(!elementsMouseClicks.isEmpty){
      _OnMouseClickChartElement(elementsMouseClicks) ;
    }
    _checkNeedRepaint() ;
  }
  
  StreamController<XChartsElement> _controller_onMouseOverChartElement = new StreamController<XChartsElement>() ;
  Stream<XChartsElement> get onMouseOverChartElement => _controller_onMouseOverChartElement.stream ;
  
  StreamController<List<XChartsElement>> _controller_onMouseClickChartElement = new StreamController<List<XChartsElement>>() ;
  Stream<List<XChartsElement>> get onMouseClickChartElement => _controller_onMouseClickChartElement.stream ;
  
  void _OnMouseOverChartElement(XChartsElement elem) {
    _controller_onMouseOverChartElement.add(elem) ;
  }
  
  
  void _OnMouseClickChartElement(List<XChartsElement> elem) {
    _controller_onMouseClickChartElement.add(elem) ;
  }

  void resize() {
    _updateSize() ;
  }
  
  void _updateSize() {

    if ( _parent == null ) {
      repaint() ;
      return ;
    }
    
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
    
    repaint() ;
  }
  
  void showAt(Element parent) {
    _checkCanvasAttached(parent) ;
    
    repaint() ;
  }
  
  bool _needRepaint = false ;
  
  void requestRepaint() {
    _needRepaint = true ;    
  }
  
  void _checkNeedRepaint() {
    if (_needRepaint) repaint() ;
  }
  
  List<XChartsElement> _chartElements ;
  
  void repaint() {
    if ( !isAttached ) return ;
    
    _needRepaint = false ;
    
    _type.clearChart(this, _context) ;
    
    _chartElements = _type.drawChart(this, _context) ;
    
    _paintControls() ;
    
  }
  
  void _paintControls() {
    
    for (var c in controls) {
      var controlElems = c.drawControl(this, _context, this.width , this.height) ;
      
      if (controlElems != null) {
        _chartElements.addAll(controlElems) ;
      }
    }
    
  }
  
  static List<XChartsData> getAllSeriesDataMean(List<XChartsDataSeries> allSeries) {
    List<XChartsData> allData = [] ;
    
    for (var s in allSeries) {
      allData.addAll(s.data) ;
    }
    
    allData.sort( (d1,d2) => d1.valueX.compareTo(d2.valueX)  ) ;
    
    for (int i = 0 ; i < allData.length ; i++) {
      XChartsData d1 = allData[i] ;
      
      num valX = d1.valueX ;
      
      num valY = d1.valueY ;
      int valYSize = 1 ;
      
      for (int j = i+1 ; j < allData.length ;) {
        XChartsData d2 = allData[j] ;
        
        if ( d2.valueX == valX ) {
          valY += d2.valueY ;
          valYSize++ ;
          
          allData.removeAt(j) ;
        }
        else {
          break ;
        }
      }
      
      if (valYSize > 1) {
        
        allData[i] = d1.clone()
                     ..valueY = valY/valYSize ;

      }
      
    }
    
    return allData ;
  }
  
  static List<XChartsData> getAllSeriesDataMax(List<XChartsDataSeries> allSeries) {
    List<XChartsData> allData = [] ;
    
    for (var s in allSeries) {
      allData.addAll(s.data) ;
    }
    
    allData.sort( (d1,d2) => d1.valueX.compareTo(d2.valueX)  ) ;
    
    for (int i = 0 ; i < allData.length ; i++) {
      XChartsData d1 = allData[i] ;
      
      num valX = d1.valueX ;
      num valY = d1.valueY ;
      
      for (int j = i+1 ; j < allData.length ;) {
        XChartsData d2 = allData[j] ;
        
        if ( d2.valueX == valX ) {
          if (d2.valueY > valY) valY = d2.valueY ;
          
          allData.removeAt(j) ;
        }
        else {
          break ;
        }
      }
      
      allData[i] = d1.clone()
                   ..valueY = valY ;
    }
    
    return allData ;
  }
  

  static List<XChartsData> getAllSeriesDataMin(List<XChartsDataSeries> allSeries) {
    List<XChartsData> allData = [] ;
    
    for (var s in allSeries) {
      allData.addAll(s.data) ;
    }
    
    allData.sort( (d1,d2) => d1.valueX.compareTo(d2.valueX)  ) ;
    
    for (int i = 0 ; i < allData.length ; i++) {
      XChartsData d1 = allData[i] ;
      
      num valX = d1.valueX ;
      num valY = d1.valueY ;
      
      for (int j = i+1 ; j < allData.length ;) {
        XChartsData d2 = allData[j] ;
        
        if ( d2.valueX == valX ) {
          if (d2.valueY < valY) valY = d2.valueY ;
          
          allData.removeAt(j) ;
        }
        else {
          break ;
        }
      }
      
      allData[i] = d1.clone()
                   ..valueY = valY ;
    }
    
    return allData ;
  }

  ////////////////////////////////////////////////////////////////////////////////
  
  List<XChartsControl> controls = [] ;
  
  void addControl(XChartsControl c) => controls.add(c) ;
  bool removeControl(XChartsControl c) => controls.remove(c) ;
  void clearControls() => controls.clear() ;
  bool containsControl(XChartsControl c) => controls.contains(c) ;
  List<XChartsControl> getControls() => new List.from( controls ) ;
  
  Rectangle _getDrawMainAreaMargins() {
    if (controls.isEmpty) return null ;
    
    int left = 0 ;
    int right = 0 ;
    int top = 0 ;
    int bottom = 0 ;
    
    for ( var c in controls ) {
      
      if (c.position == XChartsControl.CONTROL_POSITION_NORTH) {
        top += c.height ;
      }
      else if (c.position == XChartsControl.CONTROL_POSITION_SOUTH) {
        bottom += c.height ;
      }
      else if (c.position == XChartsControl.CONTROL_POSITION_WEST) {
        left += c.height ;
      }
      else if (c.position == XChartsControl.CONTROL_POSITION_EAST) {
        right += c.height ;
      }
      
    }
    
    if ( left == 0 && right == 0 && top == 0 && bottom == 0 ) return null ;
    
    return new Rectangle(left, top, right, bottom) ;
  }
  
  ////////////////////////////////////////////////////////////////////////////////
  
  List<XChartsElementHint> _hintElements = [] ;
  
  Map<XChartsElementHint, Element> _currentHintElements = {} ;
  
  void _showHints() {
    
    Iterable<XChartsElementHint> elemsIter = _hintElements.where((e) => e.containsHint()) ;
    
    Map<XChartsElementHint, Element> hintsMap = {} ;
    int distance = 0 ;
    for (var e in elemsIter) {
      var prevHint = _currentHintElements[e] ;
      if (prevHint == null) {
        
        _currentHintElements[e] = prevHint = _createHint(e,distance) ;
        //Distance hint in px
        distance += e.hintHeight ;
      }
      hintsMap[e] = prevHint ;
    }
    
    List<XChartsElementHint> del = [] ;
    
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
  
  int _parsePosition(String s) {
    if (s == null) return null ;
    if (s.endsWith("px")) return int.parse( s.substring(0 , s.length-2) ) ;
    return null ;
  }
  
  Element _createHint(XChartsElementHint chartElem, int distanceOtherHint) {
    
    int parentLeft = _canvas.documentOffset.x + (chartElem._x.toInt() + chartElem._width.toInt() + 3).toInt() - 5 ;
    
    int top = _canvas.documentOffset.y + chartElem._y.toInt() - 5;
    int parentTop = top < 170 ? (top + distanceOtherHint) : (top - distanceOtherHint);
    
    Element elem = new DivElement() ;
    elem.style.position = 'absolute' ;
    elem.style.left = "${parentLeft}px";
    elem.style.top = "${parentTop}px";
    elem.style.backgroundColor = 'rgba(255,255,255 , 0.8)' ;
    elem.style.border = '1px solid rgba(0,0,0, 0.8)' ;
    
    if ( chartElem.isHintHTML ) {
      var uriPolicy = new XChartsHTMLUriPolicy() ;
      
      NodeValidator nodeValidator = new NodeValidatorBuilder()
      ..allowImages()
      ..allowHtml5( uriPolicy: uriPolicy)
      ..allowInlineStyles()
      ..allowTextElements()
      ..allowSvg()
      ;
      
      elem.setInnerHtml(chartElem.hint, validator: nodeValidator) ;
    }
    else {
      elem.text = chartElem.hint ;  
    }
    
    this._parent.children.add(elem) ;
    
    return elem ;
  }
  
  ///////////////////////////////////////////////////////////////////////////////////////
  
  NumericalList selectSeriesXValues( [bool onlyEnabledSeries = true, bool uniqueValues = false] ) {
    NumericalList nl = new NumericalList() ;
    
    var series = onlyEnabledSeries ? this.seriesEnabled : this.series ;
    
    for (var serie in series) {
      List<num> vals = serie.getXValues() ;
      
      for (num v in vals) {
        if (uniqueValues) nl.insertSortedUnique(v) ;
        else nl.insertSorted(v) ;
      }
    }

    return nl ;
  }
  
  NumericalList selectSeriesYValues( [bool onlyEnabledSeries = true, bool uniqueValues = false] ) {
    NumericalList nl = new NumericalList() ;
    
    var series = onlyEnabledSeries ? this.seriesEnabled : this.series ;
    
    for (var serie in series) {
      List<num> vals = serie.getYValues() ;
      
      for (num v in vals) {
        if (uniqueValues) nl.insertSortedUnique(v) ;
        else nl.insertSorted(v) ;
      }
    }

    return nl ;
  }
  
  NumericalList selectedSeriesByXValue( num xValue , [bool onlyEnabledSeries = true, bool uniqueValues = false] ) {
    return selectedSeriesByXValues( xValue , xValue , uniqueValues ) ;
  }
  
  NumericalList selectedSeriesByXValues( num init, num end , [bool onlyEnabledSeries = true, bool uniqueValues = false] ) {
    NumericalList nl = new NumericalList() ;
    
    var series = onlyEnabledSeries ? this.seriesEnabled : this.series ;
    
    for (var serie in series) {
      List<num> vals = serie.getXValues() ;
      
      for (num v in vals) {
        if (v >= init && v <= end) {
          if (uniqueValues) nl.insertSortedUnique(v) ;
          else nl.insertSorted(v) ;  
        }
      }
    }

    return nl ;
  }
  
  NumericalList selectedSeriesByYValue( num yValue , [bool onlyEnabledSeries = true, bool uniqueValues = false] ) {
    return selectedSeriesByYValues( yValue , yValue , uniqueValues ) ;
  }
  
  NumericalList selectedSeriesByYValues( num init, num end , [bool onlyEnabledSeries = true, bool uniqueValues = false] ) {
    NumericalList nl = new NumericalList() ;
    
    var series = onlyEnabledSeries ? this.seriesEnabled : this.series ;
    
    for (var serie in series) {
      List<num> vals = serie.getYValues() ;
      
      for (num v in vals) {
        if (v >= init && v <= end) {
          if (uniqueValues) nl.insertSortedUnique(v) ;
          else nl.insertSorted(v) ;
        }
      }
    }

    return nl ;
  }
  
}


class XChartsHTMLUriPolicy implements UriPolicy {
  @override
  bool allowsUri(String uri) {
    return true ;
  }
}




class XChartsElement {
  
  num _x ;
  num _y ;
  num _width ;
  num _height ;
  bool _enabled ;
    
  XChartsElement( this._x , this._y , this._width , this._height, [this._enabled] ) ;
  

  bool sameDimension(num x, num y, num width, num height) {
    return this._x == x
        && this._y == y
        && this._width == width
        && this._height == height ;
  }
  
  operator == (XChartsElement o) {
    return this._x == o._x
        && this._y == o._y
        && this._width == o._width
        && this._height == o._height ;
  }
  
  int get hashCode {
    int result = 1;
    result = 31 * result + _x.toInt() ;
    result = 31 * result + _y.toInt() ;
    result = 31 * result + _width.toInt() ;
    result = 31 * result + _height.toInt() ;
    return result;
  }
  
  bool containsPoint(int x , int y) {
    return x > this._x && x <= this._x+this._width && y > this._y && y <= this._y+this._height ;
  }
  
}

class XChartsElementHint extends XChartsElement {

  int _seriesIndex ;
  int _valueIndex ;

  XChartsDataSeries _series ;
  XChartsData _data ;
  
  XChartsElementHint(num x, num y, num width, num height, this._seriesIndex, this._valueIndex, this._series, this._data, bool enabled) : super(x, y, width, height, enabled);

  operator == (XChartsElementHint o) {
    return super==(o)
        && this._seriesIndex == o._seriesIndex
        && this._valueIndex == o._valueIndex ;
  }

  int get hashCode {
      int result = super.hashCode ;
      result = 31 * result + _seriesIndex ;
      result = 31 * result + _valueIndex ;
      return result;
  }
  
  String get hint {
    if (  isHintHTML ) {
      var s = _data.hint ;
      return s.substring("<html>".length , s.length-"</html>".length) ;
    }
    else {
      return _data.hint ;
    }
  }
  
  bool get isHintHTML {
    var s = _data.hint.toLowerCase().trim() ;
    return s.startsWith("<html>") && s.endsWith("</html>") ;
  }
  
  bool containsHint() {
    return _data.hint != null ;
  }
  
  int get hintHeight => _data.hintHeight ;
  
}

class XChartsElementDetail extends XChartsElement {

  int _seriesIndex ;
  int _valueIndex ;
  num _graphicX;
  num _graphicY;
  
  XChartsElementDetail(num x, num y, num width, num height,this._seriesIndex, this._valueIndex, this._graphicX, this._graphicY, bool enabled) : super(x, y, width, height, enabled);
  
  int get seriesIndex => _seriesIndex ;
  
  int get graphicX => _graphicX ;
  int get graphicY => _graphicY ;


  
  operator == (XChartsElementDetail o) {
    return super==(o)
        && this._seriesIndex == o._seriesIndex
        && this._valueIndex == o._valueIndex ;
  }

  int get hashCode {
      int result = super.hashCode ;
      result = 31 * result + _seriesIndex ;
      result = 31 * result + _valueIndex ;
      return result;
  }

  
}


