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
        _loadPeriod((end-endDiff)-1 , end) ;
      }
      
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
          if ( s.id == serie.id ) {
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
    
    if ( this._selectInitTime < this._timelineData.initTime ) {
      this._selectInitTime = this._timelineData.initTime ;
    }
    
    if ( this._selectEndTime > this._timelineData.endTime ) {
      this._selectEndTime = this._timelineData.endTime ;
    }
    
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
  
  int _dataChangeVersion = 0 ;
  
  int get dataChangeVersion => _dataChangeVersion ;
  
  void _notifyDataChange() {
    _dataChangeVersion++ ;
    
    if (_calling_listener_onTimelineDataChanged) return ;
    
    try {
      _calling_listener_onTimelineDataChanged = true ;
      
      if (this.listener != null) this.listener.onTimelineDataChanged(this) ;
      
    }
    finally {
      _calling_listener_onTimelineDataChanged = false ; 
    }
  }
  
  bool _calling_listener_onTimelineSelectedDateChanged = false ;
  
  void _notifySelectedDateChanged() {
    if (_calling_listener_onTimelineSelectedDateChanged) return ;
    
    try {
      _calling_listener_onTimelineSelectedDateChanged = true ;
      
      if (this.listener != null) this.listener.onTimelineSelectedDateChanged(this) ;
      
    }
    finally {
      _calling_listener_onTimelineSelectedDateChanged = false ; 
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

  bool _setSelectedTime(int selInit, int selEnd) {
    if (selInit > selEnd) return false ;
    
    if ( this._selectInitTime == selInit && this._selectEndTime == selEnd ) return false ;
    
      this._selectInitTime = selInit ;      
      this._selectEndTime = selEnd ;
        
    _autoUpdateData() ;
    
    _notifySelectedDateChanged() ;
    
    return true ;
  }
  
  bool setSelectTimeByRatio(double selectInitTimeRatio, double selectEndTimeRatio) {
    if (selectInitTimeRatio < 0 || selectInitTimeRatio > 1) return false ;
    if (selectEndTimeRatio < 0 || selectEndTimeRatio > 1) return false ;
    
    if (selectInitTimeRatio > selectEndTimeRatio) return false ;
    
    int diff = this._endTime - this._initTime ;
    
    return _setSelectedTime(
      (this._initTime + ( diff * selectInitTimeRatio )).toInt() ,
      (this._initTime + ( diff * selectEndTimeRatio )).toInt()
    ) ;
  }
  
  bool setSelectInitTimeByRatio(double selectInitTimeRatio) {
    if (selectInitTimeRatio < 0 || selectInitTimeRatio > 1) return false ;
    
    int diff = this._endTime - this._initTime ;
    
    int time = (this._initTime + ( diff * selectInitTimeRatio )).toInt() ;
    
    return _setSelectedTime(time, this._selectEndTime) ;
  }

  bool setSelectEndTimeByRatio(double selectEndTimeRatio) {
    if (selectEndTimeRatio < 0 || selectEndTimeRatio > 1) return false ;
    
    int diff = this._endTime - this._initTime ;
    
    int time = (this._initTime + ( diff * selectEndTimeRatio )).toInt() ;
    
    return _setSelectedTime(this._selectInitTime , time) ;
  }
  
  bool setSelectTime(int selectInitTime, int selectEndTime) {
    return _setSelectedTime(selectInitTime, selectEndTime) ;
  }
  
  bool setSelectInitTime(int selectInitTime) {
    return _setSelectedTime(selectInitTime, this._selectEndTime) ;
  }
  
  bool setSelectEndTime(int selectEndTime) {
    return _setSelectedTime(this._selectInitTime, selectEndTime) ;
  }
  
  List<XChartsDataSeries> selectSeries() {
    return selectSeriesByTime( this.selectInitTime , this.selectEndTime ) ;
  }
  
  List<XChartsDataSeries> selectSeriesCompacted(num interval) {
    return _compactSeriesDates( selectSeries() , interval);
  }
  
  List<XChartsDataSeries> selectSeriesByTimeCompacted(int initTime, int endTime ,num interval) {
    return _compactSeriesDates( selectSeriesByTime( initTime, endTime ) , interval);
  }
  
  List<XChartsDataSeries> _compactSeriesDates(List<XChartsDataSeries> series, int interval, [bool clone = true]) {
    List<XChartsDataSeries> seriesCompacted = [] ;
    
    for (var serie in series) {
      var serie2 = clone ? serie.cloneOnlySerie() : serie ;
      serie2.data = _compactDatas(serie2.data , interval, clone);
      seriesCompacted.add(serie2) ;
    }
    
    return seriesCompacted ;
  }
  
  List<XChartsData> _compactDatas(List<XChartsData> datas, int interval, [bool clone = true]) {
     List<XChartsData> datasCompacted = [] ;

     List<XChartsData> buffer = [] ;
     
     for (var data in datas) {
       if ( buffer.isEmpty ) {
         buffer.add(data) ;
       }
       else {
         num timeRange = data.x - buffer.first.x ;
         
         if (timeRange > interval) {
           datasCompacted.add( _calcDataMean(buffer, clone) ) ;
           buffer.clear();
         }
         
         buffer.add(data) ;
       }
     }
       
     return datasCompacted ;
  }
  
  XChartsData _calcDataMean(List<XChartsData> datas, [bool clone = true]) {
    var centerData = datas[ datas.length ~/ 2 ] ;
    
    if (clone) centerData = centerData.clone() ;
    
    num totalY = 0 ;
    
    for (var data in datas) {
      totalY += data.valueY ;
    }
    
    centerData.valueY = totalY ~/ datas.length ;
    
    return centerData ;
  }
  
  List<int> getValidTimeRangeValues(int selInit, int selEnd) {
    
    List<int> values = new List(2);

    if (selInit < this._timelineData.initTime) {
      values[0] = _timelineData.initTime ;
    }
    else {
      values[0] = selInit ;
    }
    
    if (selEnd > this._timelineData.endTime) {
      values[1] = _timelineData.endTime ;
    }
    else {
      values[1] = selEnd ;
    }
    
    return values;
  }
  
  List<XChartsDataSeries> selectSeriesByTime(int initTime, int endTime) {
    if (initTime < this.initTime) throw new ArgumentError('initTime out of range: $initTime < ${ this._initTime }') ;
    if (endTime > this.endTime) throw new ArgumentError('endTime out of range: $endTime > ${ this._endTime }') ;
    
    List<XChartsDataSeries> series = [] ;
    
    if ( this._timelineData == null ) return series ;
    
    for (var s in this._timelineData.series) {
      var d = _selectData( s.data, initTime, endTime ) ;
      
      if (d.isNotEmpty) {
        var serie = new XChartsDataSeries( s.id, s.label, d, s.color, s.enabled ) ;
        serie.properties.addAll( s.properties );
        
        series.add(serie) ;
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
  
  void onTimelineDataChanged( XChartsTimelineDataHandler timelineDataHandler ) {}
  void onTimelineSelectedDateChanged( XChartsTimelineDataHandler timelineDataHandler ) {}
  
}

