//+------------------------------------------------------------------+
//|                                                     ExpertCB.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#define TREND_UP 9999
#define TREND_DN -9999

#include <Expert\ExpertSignal.mqh>

//+------------------------------------------------------------------+
class CExpertSignalCB : public CExpertSignal
  {

protected:
   /*
      int               v_stoploss;
      int               v_takeprofit;
      bool              v_use;
      int               v_delay;
      */

   //   double            m_exit_direction;
   //   double            m_exit_weight;         // "exit weight" of a signal in a combined filter
   //   int               m_threshold_exit;
   //   CArrayObj         exit_signals;        // array of additional filters (maximum number of fileter is 64)
   //   bool              IsExitSignal(CExpertSignal *filter);


public:
                     CExpertSignalCB(void);
                    ~CExpertSignalCB(void);

   /*
   bool              VUse(void) {return v_use;}
   int               VDelay(void) {return v_delay;}
   double            VStopLevel(void) {return v_stoploss;}
   double            VTakeLevel(void) {return v_takeprofit;}
   void              StopLevel(int value) { v_stoploss = value; CExpertSignal::StopLevel(value); }
   void              TakeLevel(int value) { v_takeprofit = value; CExpertSignal::TakeLevel(value); }
   void              VUse(int value) { v_use = value; if(v_use) {TakeLevel(0); StopLevel(0);}}
   void              VDelay(int value) {v_delay=value*60;}
   */
   virtual double            Direction();
   virtual void              SetDirection(void)                             { m_direction=Direction(); }
   double            GetDirection(void)         {return m_direction;}
   void              setDir(double value) {m_direction=value;}
   //   double            ExitDirection(void);
   //   void              SetExitDirection(void) {m_exit_direction = Direction(true);}
   //   double              GetExitDirection(void) {return m_exit_direction;}
   //   bool              CheckExitLong(double &price);
   //   bool              CheckExitShort(double &price);
   //   void              ExitWeight(double value)      { m_exit_weight=value;  Print(__FUNCTION__,": m_exit_weight=",m_exit_weight);        }
   //   double            ExitWeight(void)      { return m_exit_weight;    }
   //  void              ThresholdExit(int value) { m_threshold_exit=value; }
   // bool              SetAsExitSignal(CExpertSignalCB *signal);
   //bool              SetAsExitSignal(CExpertSignal *signal);
   //    virtual bool      AddFilter(CExpertSignal *filter,bool asExit);
   //  virtual bool      InitIndicators(CIndicators *indicators);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CExpertSignalCB::CExpertSignalCB(void)
/*: v_stoploss(0),
   v_takeprofit(0),
   v_use(false),
   v_delay(0)
   */
//  ,
//  m_exit_direction(0),
//  m_exit_weight(0),
//  m_threshold_exit(0)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CExpertSignalCB::~CExpertSignalCB(void)
  {
  }
/****************
//+------------------------------------------------------------------+
//| Setting an additional filter                                     |
//+------------------------------------------------------------------+
bool CExpertSignalCB::AddFilter(CExpertSignal *filter, bool asExit)
{
//--- check pointer
 if(filter==NULL)
    return(false);
//--- primary initialization of the filter
 if(!filter.Init(m_symbol,m_period,m_adjusted_point))
    return(false);
//--- add the filter to the array of filters
 if(asExit)
   {
    if(!exit_signals.Add(filter))
       return(false);
   }
 else
   {
    if(!m_filters.Add(filter))
       return(false);
   }
 filter.EveryTick(m_every_tick);
 filter.Magic(m_magic);
//--- succeed
 return(true);
}

//+------------------------------------------------------------------+
//| Create indicators                                                |
//+------------------------------------------------------------------+
bool CExpertSignalCB::InitIndicators(CIndicators *indicators)
{
//--- check pointer
 if(indicators==NULL)
    return(false);

 if (CExpertSignal::InitIndicators(indicators) == false)
   return (false);

//---
 CExpertSignal *filter;
 int            total=exit_signals.Total();
//--- gather information about using of timeseries
 for(int i=0;i<total;i++)
   {
    filter=exit_signals.At(i);
    m_used_series|=filter.UsedSeries();
   }
//--- create required timeseries
 if(!CExpertBase::InitIndicators(indicators))
    return(false);


//--- initialization of indicators and timeseries in the additional filters
 for(int i=0;i<total;i++)
   {
    filter=exit_signals.At(i);
    filter.SetPriceSeries(m_open,m_high,m_low,m_close);
    filter.SetOtherSeries(m_spread,m_time,m_tick_volume,m_real_volume);
    if(!filter.InitIndicators(indicators))
       return(false);
   }
//--- succeed
 return(true);
}
*/
//+------------------------------------------------------------------+
//| Detecting the "weighted" direction                               |
//+------------------------------------------------------------------+
double CExpertSignalCB::Direction()
  {
   long   mask;
   double direction;
   int trend_direction=0;

   int longCond= LongCondition();
   int shortCond= ShortCondition();
   double result = 0;
   result = m_weight*(longCond-shortCond);
//   double result=m_weight*(LongCondition()-ShortCondition());

   int    number=(result==0.0)? 0 : 1;      // number of "voted"
//---
   int    total= 0;
   total= m_filters.Total();

Print(__FUNCTION__,": number=",number,": result=",result, " total=",total);

//--- loop by filters
   for(int i=0; i<total; i++)
     {
      //--- mask for bit maps
      mask=((long)1)<<i;
      //--- check of the flag of ignoring the signal of filter
      if((m_ignore&mask)!=0)
         continue;

      CExpertSignal *filter=NULL;
      filter=m_filters.At(i);

      //--- check pointer
Print(__FUNCTION__,": filter=",filter);
      if(filter==NULL)
         continue;

      // if(IsExitSignal(filter))
      //    continue;

      direction=filter.Direction();   // alle Filter in der Kette

      //--- the "prohibition" signal
      if(direction==EMPTY_VALUE)
         return(EMPTY_VALUE);
      //--- CB SignalTrend
      if(direction==TREND_UP)
        {
         trend_direction=1;
         direction=0;
         number--;
        }
      if(direction==TREND_DN)
        {
         trend_direction=-1;
         direction=0;
         number--;
        }

      if(direction != 0.0)
        {
         //--- check of flag of inverting the signal of filter
         if((m_invert&mask)!=0)
            result-=direction;
         else
            result+=direction;

        }
      //   Print(__FUNCTION__,": number=",number,": result=",result, " direction=",direction," trend_direction=",trend_direction);
      number++;

     }


//--- normalization
   if(number!=0)
      result/=number;

//  Print(__FUNCTION__,": result=",result," trend_direction=",trend_direction);
   if(result > 0 && trend_direction<0)
      result=EMPTY_VALUE;
   if(result < 0 && trend_direction>0)
      result=EMPTY_VALUE;
//
   Print(__FUNCTION__,": result=",result," trend_direction=",trend_direction);
//--- return the result
   return(result);
  }

/*
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//bool CExpertSignalCB::SetAsExitSignal(CExpertSignalCB *filter)
bool CExpertSignalCB::SetAsExitSignal(CExpertSignal *filter)
  {
   if(!exit_signals.Add(filter))
     {
      Print(__FUNCTION__, ": failed to add Exit Signal");
      return(false);
     }
//  Print(__FUNCTION__, ": exit_weight=",filter.ExitWeight());
   return true;
  }
bool CExpertSignalCB::IsExitSignal(CExpertSignal *filter)
{
    int    total=exit_signals.Total();
     for(int i=0; i<total; i++)
     {
       CExpertSignal *f=exit_signals.At(i);
        if (filter == f)
        {
        //  Print(__FUNCTION__,": IsExitSignal=true");
          return true;
        }
     }
    return false;
}
*/

/*
//+------------------------------------------------------------------+
//| Detecting the "weighted" direction                               |
//+------------------------------------------------------------------+
double CExpertSignalCB::ExitDirection(void)
  {
   long   mask;
   double direction;
   int trend_direction=0;
   if(m_exit_weight==0)
      m_exit_weight=1;
   int longCond= LongCondition();
   int shortCond= ShortCondition();
   double result =m_exit_weight*(longCond-shortCond);

//   double result=m_weight*(LongCondition()-ShortCondition());

   int    number=(result==0.0)? 0 : 1;      // number of "voted"
//---
   int    total=exit_signals.Total();

//   Print(__FUNCTION__,": result=",result, " m_exit_weight=",m_exit_weight, " longCond=",longCond," shortCond=",shortCond," total=",total);
//--- loop by filters
   for(int i=0; i<total; i++)
     {

      //     CExpertSignalCB *filter=exit_signals.At(i);
      CExpertSignal *filter=exit_signals.At(i);
      //--- check pointer
      if(filter==NULL)
         continue;
      //     direction=filter.ExitDirection();   // alle Filter in der Kette
      direction=filter.Direction();   // alle Filter in der Kette


      result+=direction;
      Print(__FUNCTION__,": number=",number," result=",result, " direction=",direction, " total=",total);
      number++;

     }

//--- normalization
   if(number!=0)
      result/=number;
//
   if(result != 0)
      Print(__FUNCTION__,": result=",result);
//--- return the result
   return(result);
  }
  */

/*
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Generating a signal for closing of a long position               |
//+------------------------------------------------------------------+
bool CExpertSignalCB::CheckExitLong(double &price)
{
 bool   result   =false;
//--- check of exceeding the threshold value
 if(-m_exit_direction>=m_threshold_exit)
   {
    Print(__FUNCTION__,": -m_exit_direction>=m_threshold_exit=",-m_exit_direction>=m_threshold_exit);
    //--- there's a signal
    result=true;
    //--- try to get the level of closing
    if(!CloseLongParams(price))
       result=false;
   }
//--- zeroize the base price
 m_base_price=0.0;
//--- return the result
 return(result);
}
//+------------------------------------------------------------------+
//| Generating a signal for closing a short position                 |
//+------------------------------------------------------------------+
bool CExpertSignalCB::CheckExitShort(double &price)
{
 bool   result   =false;
//--- check of exceeding the threshold value
 if(m_exit_direction>=m_threshold_exit)
   {
    Print(__FUNCTION__,": m_exit_direction>=m_threshold_exit=",m_exit_direction>=m_threshold_exit);
    //--- there's a signal
    result=true;
    //--- try to get the level of closing
    if(!CloseShortParams(price))
       result=false;
   }
//--- zeroize the base price
 m_base_price=0.0;
//--- return the result
 return(result);
}
//+------------------------------------------------------------------+
*/
