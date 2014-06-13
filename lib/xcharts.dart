library xcharts;

import 'dart:html';
import 'dart:async';

part './xcharts_types.dart' ;

class XChartsDataSeries {
  
  String name ;
  List<XChartsData> data ;
  String color ;
  
  XChartsDataSeries( this.name , this.data , [ this.color ]) ;
  
  List<String> getLabels() {
    List<String> labels = [] ;
    
    for (var d in data) {
      labels.add( d.label ) ;
    }
    
    return labels ;
  }

  List<num> getLabelsValues() {
    List<num> labelsVals = [] ;
    
    for (var d in data) {
      labelsVals.add( d.labelValue ) ;
    }
    
    return labelsVals ;
  }

  
}

class XChartsData {
  
  num value ;
  num labelValue ;
  String _label ;
  String hint ;
  
  String get label => _label != null ? _label : labelValue.toString() ;
  
  XChartsData( this.value , this.labelValue , [this._label , this.hint]) ;
  
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
  
  /////////////////////////////////////////////////////////////////////////////////////
  
  List<XChartsDataSeries> _series = [] ;
  
  void addSeries(XChartsDataSeries serie) => _series.add(serie) ;
  bool removeSeries(XChartsDataSeries serie) => _series.remove(serie) ;
  bool containsSeries(XChartsDataSeries serie) => _series.contains(serie) ;
  
  /////////////////////////////////////////////////////////////////////////////////////
  
  List<String> getLabelsNames() => getLabelsNamesAndLabelsValues()[0] ;
  
  List<List> getLabelsNamesAndLabelsValues() {
    Map<num,String> labelsMap = getLabelsMap() ;
    
    List<num> vals = _getLabelsValues(labelsMap) ;
    
    List<String> labels = [] ;
    
    for (int i = 0 ; i < vals.length ; i++) {
      num v = vals[i] ;
      String s = labelsMap[v] ;
      labels.add(s) ;
    }
    
    return [ labels , vals ] ;
  }
  
  List<num> getLabelsValues() => _getLabelsValues( getLabelsMap() ) ;
  
  List<num> _getLabelsValues(Map<num,String> labelsMap) {
    List<num> labelsVals = [] ;
    
    for ( var v in labelsMap.keys ) {
      labelsVals.add(v) ;
    }
    
    labelsVals.sort( (n1,n2) => n1<n2 ? -1 : (n1==n2 ? 0 : 1) ) ;
    
    return labelsVals ;
  }
  
  Map<num,String> getLabelsMap() {
    
    Map<num,String> labelsMap = {} ;
    
    for (var s in _series) {
      List<String> labels = s.getLabels() ;
      List<num> labelsVals = s.getLabelsValues() ;
      
      for (int i = 0 ; i < labels.length ; i++) {
        var l = labels[i] ;
        var lv = labelsVals[i] ;
        
        labelsMap[lv] = l ;
      }
    }
   
    return labelsMap ;
  }
  
  /////////////////////////////////////////////////////////////////////////////////////
  
  Element _parent ;
  
  int _width ;
  int _height ;
  
  int get width => _width ;
  int get height => _height ;
  
  StreamSubscription<MouseEvent> _onMouseMoveSubscription ;
  StreamSubscription<MouseEvent> _onMouseClickSubscription ;
  
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
    
    _onMouseMoveSubscription = _canvas.onMouseMove.listen( _processMouseMove ) ;
    _onMouseClickSubscription = _canvas.onClick.listen( _processMouseClick ) ;
    
    _updateSize() ;
    
  }
  
  void _processMouseMove(MouseEvent e) {
    if (_chartElements == null) return ;
    
    num x = e.offset.x ;
    num y = e.offset.y ;

    for (var e in _chartElements) {
      if ( e.containsPoint(x, y) ) {
        _OnMouseOverChartElement(e) ;
      }
    }
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
  
}

class XChartsElement {
  
  num x ;
  num y ;
  num width ;
  num height ;
  
  int seriesIndex ;
  int valueIndex ;
  
  XChartsElement( this.x , this.y , this.width , this.height , this.seriesIndex , this.valueIndex , this.series , this.data ) ;
  
  XChartsDataSeries series ;
  XChartsData data ;
  
  bool containsPoint(int x , int y) {
    return x > this.x && x <= this.x+this.width && y > this.y && y <= this.y+this.height ;
  }
  
}

