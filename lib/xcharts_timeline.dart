part of xcharts ;

class XChartsTimelineDataHandler {
  
  int _initTime ;
  int _endTime ;
  
  XChartsTimelineDataPopulator _populator ;
  XChartsTimelineListener listener ;
  
  XChartsTimelineDataHandler.byDateTime( DateTime initTime , DateTime endTime , this._populator , this.listener ) {
    this._initTime = initTime.millisecondsSinceEpoch ;
    this._endTime = endTime.millisecondsSinceEpoch ;
  }
  
  XChartsTimelineDataHandler( this._initTime , this._endTime , this._populator , this.listener ) {

  }
  
  int get initTime => _initTime ;
  int get endTime => _endTime ;
  
  XChartsTimelineDataPopulator get populator => _populator ;
  
  void setTime(int initTime, int endTime) {
    if (this._initTime == initTime && this._endTime == endTime) return ;
    
    this._initTime = initTime ;
    this._endTime = endTime ;
    _autoUpdateData() ;
  }
  
  void setInitTime(int initTime) {
    if (this._initTime == initTime) return ;
    
    this._initTime = initTime ;
    _autoUpdateData() ;
  }

  void setEndTime(int endTime) {
    if (this._endTime == endTime) return ;
    
    this._endTime = endTime ;
    _autoUpdateData() ;
  }
  
  void setPopulator(XChartsTimelineDataPopulator populator) {
    this._populator = populator ;
    _autoUpdateData() ;
  }
  
  void clearLoadedData() {
    this._timelineData = null ;
  }

  void refreshData() {
    clearLoadedData() ;
    loadData() ;
  }
  
  void loadData() {
    _updateData() ;
  }
  
  bool _autoUpdateDataActive = true ;
  
  bool get autoUpdateData => _autoUpdateDataActive ;
  
  void setAutoUpdateData(bool autoUpdate) {
    if (_autoUpdateDataActive == autoUpdate) return ;
    
    _autoUpdateDataActive = autoUpdate ;
    _autoUpdateData() ;
  }
  
  void setAutoUpdateDataAndLoadData(bool autoUpdate) {
    _autoUpdateDataActive = autoUpdate ;
    _updateData() ;
  }
  
  void _autoUpdateData() {
    if (_autoUpdateDataActive) {
      _updateData() ;
    }
  }
  
  XChartsTimelineData _timelineData ;
  
  bool _calling_updateData = false ;
  
  void _updateData() {
    if (_calling_updateData) return ;
    
    try {
      _calling_updateData = true ;
      
      _updateDataImplem() ;
    }
    finally {
      _calling_updateData = false ;
    }
    
  }
  
  List<Point<int>> _loadingPeriods = [] ;
  
  void _updateDataImplem() {
    if (this._populator == null) return ;
    
    int init = this._selectInitTime ;
    int end = this._selectEndTime ;
    
    if ( this._timelineData == null ) {
      _loadPeriod(init, end) ;
    }
    else {
    
      int initDiff = this._timelineData.initTime - init ;
      
      if (initDiff > 0) {
        _loadPeriod(init , init+initDiff+1) ;
      }
      
      int endDiff = end - this._timelineData.endTime ;
      
      if (endDiff > 0) {
        _loadPeriod(end-1 , end+endDiff) ;
      }
      
      _notifyDataChange() ;
      
    }
    
  }
  
  bool _loadPeriod(int init, int end) {
    Point<int> period = new Point(init,end) ;

    if ( _loadingPeriods.contains(period) ) {
      return false ;
    }
    
    print("load period> $period") ;
    
    _loadingPeriods.add(period) ;
    
    this._populator.loadData( init , end ).then( (d) {
      _loadingPeriods.remove(period) ;
      
      if (d == null) {
        _updateData() ;
      }
      else {
        _addToTimelineData(d) ;
      }
    }) ;
    
    return true ;
  }
  
  void _addToTimelineData(XChartsTimelineData timelineData) {
    if ( timelineData.isEmptySeries ) {
      
      if ( this._timelineData == null ) {
        this._timelineData = new XChartsTimelineData( timelineData.initTime , timelineData.endTime , []) ;
      }
      else {
        if ( timelineData.initTime < this._timelineData.initTime ) this._timelineData.initTime = timelineData.initTime ;
        if ( timelineData.endTime > this._timelineData.endTime ) this._timelineData.endTime = timelineData.endTime ;
      }
      
      _notifyDataChange() ;
      
      return ;
    }

    for ( XChartsDataSeries serie in timelineData.series ) {
      serie.sortData() ;
      
      while ( serie.data.isNotEmpty && serie.data.first.valueX < this.initTime ) {
        serie.data.removeAt(0) ;
      }
      
      while ( serie.data.isNotEmpty && serie.data.last.valueX > this.endTime ) {
        serie.data.removeAt( serie.data.length-1 ) ;
      }
    }
    
    List<XChartsDataSeries> newSeries = [] ;
    
    if ( this._timelineData == null ) {
      this._timelineData = new XChartsTimelineData(0,0,[]) ;
      newSeries = timelineData.series ;
    }
    else {
      newSeries = [] ;
      
      for ( XChartsDataSeries serie in timelineData.series ) {
        bool join = false ;
        
        for ( XChartsDataSeries s in this._timelineData.series ) {
          if ( s.name == serie.name ) {
            s.data = _joinData( s.data , serie.data ) ;
            join = true ;
            break ;
          }
        }
        
        if (!join) {
          newSeries.add(serie) ;
        }
      }
    }
    
    for ( XChartsDataSeries serie in newSeries ) {
      this._timelineData.addSerie(serie) ;
    }
    
    this._timelineData.initTime = Math.min( Math.max(this.initTime, timelineData.initTime) , this._timelineData.seriesInitTime ) ;
    this._timelineData.endTime = Math.max( Math.min(this.endTime , timelineData.endTime) , this._timelineData.seriesEndTime ) ;
    
    _notifyDataChange() ;
  }
  
  List<XChartsData> _joinData( List<XChartsData> data1 , List<XChartsData> data2 ) {
    List<XChartsData> data3 = [] ;
    
    data3.addAll(data1) ;
    data3.addAll(data2) ;
    
    data3.sort( (XChartsData d1, XChartsData d2) {
      return d1.valueX.compareTo(d2.valueX) ;
    } ) ;
    
    for (int i = 1 ; i < data3.length ;) {
      int prevIdx = i-1 ;
      
      var prev = data3[prevIdx] ;
      var d = data3[i] ;
      
      if ( prev.valueX == d.valueX ) {
        data3.removeAt(prevIdx) ;
      }
      else {
        i++ ;
      }
    }
    
    return data3 ;
  }
  
  bool _calling_listener_onTimelineDataChanged = false ;
  
  void _notifyDataChange() {
    
    if (_calling_listener_onTimelineDataChanged) return ;
    
    try {
      _calling_listener_onTimelineDataChanged = true ;
      
      if (this.listener != null) this.listener.onTimelineDataChanged(this) ;
      
    }
    finally {
      _calling_listener_onTimelineDataChanged = false ; 
    }
    
    
    
  }
  
  List<XChartsDataSeries> getSeries() {
    return new List.from( this._timelineData.series ) ;
  }
  
  bool get isDataLoaded => this._timelineData != null ;
  
  int _selectInitTime ;
  int _selectEndTime ;
  
  int get selectInitTime => this._selectInitTime != null ? this._selectInitTime : this._initTime ;
  int get selectEndTime => this._selectEndTime != null ? this._selectEndTime : this._endTime ;
  
  double get selectInitTimeAsRatio {
    int diff = this._endTime - this._initTime ;
    return ( this._selectInitTime - this._initTime ) / diff ; 
  }
  
  double get selectEndTimeAsRatio {
    int diff = this._endTime - this._initTime ;
    return ( this._selectEndTime - this._initTime ) / diff ; 
  }

  bool setSelectTimeByRatio(double selectInitTimeRatio, double selectEndTimeRatio) {
    if (selectInitTimeRatio < 0 || selectInitTimeRatio > 1) return false ;
    if (selectEndTimeRatio < 0 || selectEndTimeRatio > 1) return false ;
    
    if (selectInitTimeRatio > selectEndTimeRatio) return false ;
    
    int diff = this._endTime - this._initTime ;
    
    this._selectInitTime = (this._initTime + ( diff * selectInitTimeRatio )).toInt() ;
    this._selectEndTime = (this._initTime + ( diff * selectEndTimeRatio )).toInt() ;
    
    _autoUpdateData() ;
    
    return true ;
  }
  
  bool setSelectInitTimeByRatio(double selectInitTimeRatio) {
    if (selectInitTimeRatio < 0 || selectInitTimeRatio > 1) return false ;
    
    int diff = this._endTime - this._initTime ;
    
    int time = (this._initTime + ( diff * selectInitTimeRatio )).toInt() ;
    
    if (time > this._selectEndTime) return false ;
    
    this._selectInitTime = time ;
    
    _autoUpdateData() ;
    
    return true ;
  }

  bool setSelectEndTimeByRatio(double selectEndTimeRatio) {
    if (selectEndTimeRatio < 0 || selectEndTimeRatio > 1) return false ;
    
    int diff = this._endTime - this._initTime ;
    
    int time = (this._initTime + ( diff * selectEndTimeRatio )).toInt() ;
    
    if (time < this._selectInitTime) return false ;
    
    this._selectEndTime = time ;
    
    _autoUpdateData() ;
    
    return true ;
  }
  
  bool setSelectTime(int selectInitTime, int selectEndTime) {
    if (selectInitTime > selectEndTime) return false ;
    
    this._selectInitTime = selectInitTime ;
    this._selectEndTime = selectEndTime ;
    
    _autoUpdateData() ;
    
    return true ;
  }
  
  bool setSelectInitTime(int selectInitTime) {
    if (selectInitTime > this._selectEndTime) return false ;
    this._selectInitTime = selectInitTime ;
    
    _autoUpdateData() ;
    
    return true ;
  }
  
  bool setSelectEndTime(int selectEndTime) {
    if (selectEndTime < this._selectInitTime) return false ;
    this._selectEndTime = selectEndTime ;
    
    _autoUpdateData() ;
    
    return true ;
  }
  
  List<XChartsDataSeries> selectSeries() {
    return selectSeriesByTime( this.selectInitTime , this.selectEndTime ) ;
  }
  
  List<XChartsDataSeries> selectSeriesByTime(int initTime, int endTime) {
    if (initTime < this.initTime) throw new ArgumentError('initTime out of range: $initTime < ${ this._initTime }') ;
    if (endTime > this.endTime) throw new ArgumentError('endTime out of range: $endTime > ${ this._endTime }') ;
    
    List<XChartsDataSeries> series = [] ;
    
    if ( this._timelineData == null ) return series ;
    
    for (var s in this._timelineData.series) {
      var d = _selectData( s.data, initTime, endTime ) ;
      
      if (d.isNotEmpty) {
        series.add( new XChartsDataSeries( s.name, d ) ) ;
      }
    }
    
    return series ;
  }
  
  List<XChartsData> _selectData(List<XChartsData> data, int initTime, int endTime) {
    return new List.from( data.where( (d) => d.valueX >= initTime && d.valueX <= endTime ) ) ;
  }
  
}

class XChartsTimelineData {
  
  int initTime ;
  int endTime ;
  
  List<XChartsDataSeries> _series ;
  
  XChartsTimelineData(this.initTime , this.endTime , this._series) ;
  
  XChartsTimelineData.bySeries(this._series , [int initTime , int endTime]) {
    if ( this._series == null || this._series.isEmpty ) {
      this._series = [] ;
      this.initTime = initTime != null ? initTime : 0 ;
      this.endTime = endTime != null ? endTime : 0 ;
    }
    else {
      List<num> minSeriesValue = new List.from( _series.map( (s) => s.data.first.valueX ) ) ;
      minSeriesValue.sort( (num n1, num n2) => n1.compareTo(n2) ) ;
      
      List<num> maxSeriesValue = new List.from( _series.map( (s) => s.data.last.valueX ) ) ;
      maxSeriesValue.sort( (num n1, num n2) => n2.compareTo(n1) ) ;
      
      this.initTime = minSeriesValue.first ;
      this.endTime = maxSeriesValue.last ;
    }
  }
  
  bool get isEmptySeries => this._series == null || this._series.isEmpty ;
  
  List<XChartsDataSeries> get series => new List.from( _series ) ;
 
  void addSerie(XChartsDataSeries serie) {
    serie.sortData() ;
    this._series.add(serie) ;
  }
  
  num get seriesInitTime => ( new List.from( series.map((s) => s.data.first.valueX ) )..sort( (num a, num b) => a.compareTo(b) ) ).first ;
  num get seriesEndTime => ( new List.from( series.map((s) => s.data.last.valueX ) )..sort( (num a, num b) => a.compareTo(b) ) ).last ;
  
}

abstract class XChartsTimelineDataPopulator {
  
  Future<XChartsTimelineData> loadData(int initTime, int endTime) ;
  
}

abstract class XChartsTimelineListener {
  
  void onTimelineDataChanged( XChartsTimelineDataHandler timelineDataHandler ) ;
  
}

