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
    _updateData() ;
  }
  
  void setInitTime(int initTime) {
    if (this._initTime == initTime) return ;
    
    this._initTime = initTime ;
    _updateData() ;
  }

  void setEndTime(int endTime) {
    if (this._endTime == endTime) return ;
    
    this._endTime = endTime ;
    _updateData() ;
  }
  
  void setPopulator(XChartsTimelineDataPopulator populator) {
    this._populator = populator ;
    _updateData() ;
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
  
  XChartsTimelineData _timelineData ;
  
  void _updateData() {
    if (this._populator == null) return ;
    
    if ( this._timelineData == null ) {
      XChartsTimelineData timelineData = this._populator.loadData( _initTime , _endTime ) ;
      _addToTimelineData(timelineData) ;
    }
    else {
    
      int initDiff = this._timelineData.initTime - _initTime ;
      
      if (initDiff > 0) {
        XChartsTimelineData timelineData = this._populator.loadData( _initTime , _initTime+initDiff+1 ) ;
        _addToTimelineData(timelineData) ;
      }
      
      int endDiff = _endTime - this._timelineData.endTime ;
      
      if (endDiff > 0) {
        XChartsTimelineData timelineData = this._populator.loadData( _endTime-1 , _endTime+endDiff ) ;
        _addToTimelineData(timelineData) ;
      }
      
    }
    
  }
  
  void _addToTimelineData(XChartsTimelineData timelineData) {

    if ( this._timelineData == null ) {
      this._timelineData = timelineData ;
      _notifyDataChange() ;
      return ;
    }
    
    List<XChartsDataSeries> newSeries = [] ;
    
    for ( XChartsDataSeries serie in timelineData.series ) {
    
      bool join = false ;
      
      for ( XChartsDataSeries s in this._timelineData.series ) {
        if ( s.name == serie.name ) {
          s.data = _joinData( s.data , serie.data ) ;
          join = true ;
        }
      }
      
      if (!join) {
        newSeries.add(serie) ;
      }
      
    }
    

    for ( XChartsDataSeries serie in newSeries ) {
      this._timelineData.series.add(serie) ;
    }
    
    if ( this._timelineData.initTime > timelineData.initTime ) {
      this._timelineData.initTime = timelineData.initTime ;
    }
    
    if ( this._timelineData.endTime < timelineData.endTime ) {
      this._timelineData.endTime = timelineData.endTime ;
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
  
  void _notifyDataChange() {
    if (this.listener != null) this.listener.onTimelineDataChanged(this) ;
  }
  
  List<XChartsDataSeries> getSeries() {
    return new List.from( this._timelineData.series ) ;
  }
  
}

class XChartsTimelineData {
  
  int initTime ;
  int endTime ;
  
  List<XChartsDataSeries> series ;
  
  XChartsTimelineData(this.initTime , this.endTime , this.series) ;
  
  XChartsTimelineData.bySeries(this.series) {
    List<num> minSeriesValue = new List.from( series.map( (s) => s.data.first.valueX ) ) ;
    minSeriesValue.sort( (num n1, num n2) => n1.compareTo(n2) ) ;
    
    List<num> maxSeriesValue = new List.from( series.map( (s) => s.data.last.valueX ) ) ;
    maxSeriesValue.sort( (num n1, num n2) => n2.compareTo(n1) ) ;
    
    this.initTime = minSeriesValue.first ;
    this.endTime = maxSeriesValue.last ;
  }
  
}

abstract class XChartsTimelineDataPopulator {
  
  XChartsTimelineData loadData(int initTime, int endTime) ;
  
}

abstract class XChartsTimelineListener {
  
  void onTimelineDataChanged( XChartsTimelineDataHandler timelineDataHandler ) ;
  
}

