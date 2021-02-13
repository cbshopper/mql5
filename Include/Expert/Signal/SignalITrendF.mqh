//+------------------------------------------------------------------+
//|                                                    SignalTrendF.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
#include <CB\CB_IndicatorHelper.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals tend filter                                        |
//| Type=SignalAdvanced                                              |
//| Name=SignalTrendFilter                                           |
//| ShortName=STF                                                    |
//| Class=CSignalITF                                                 |
//| Page=signal_trend_filter                                         |
//| Parameter=TrendPeriod,int,50,Trend Period                             |
//| Parameter=TrendMethod,ENUM_MA_METHOD,MODE_SMA,Method of averaging     |
//| Parameter=TrendMiniff,int,0,Trend Period min.Diff                    |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalTrendF                                              |
//| Appointment: Class trading signals trend filter.                 |
//|              Derives from class CExpertSignal.                   |
//+------------------------------------------------------------------+
class CSignalTrend : public CExpertSignal
  {
protected:
   //--- input parameters
   int               m_period;
   ENUM_MA_METHOD    m_method;
   int               m_mindiff;
   int               m_ptr;

public:
                     CSignalITF(void);
                    ~CSignalITF(void);
   //--- methods initialize protected data
   void              TrendPeriod(int value)  { m_period=value; }
    void             TrendMethod(int value)  { m_method=value; }
   void              TrendMindiff(int value)     { m_mindiff=value;    }
   //--- methods of checking conditions of entering the market
   virtual double    Direction(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalTrend::CSignalTrend(void) : m_period(50),
                               m_method(MODE_EMA),
                               m_mindiff(0),
                               m_ptr(INVALID_HANDLE)
  {
    m_ptr=iMA(symbol,period,ma_period,0,ma_method,PRICE_CLOSE);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalTrend::~CSignalTrend(void)
  {
     
  }
//+------------------------------------------------------------------+
//| Check conditions for time filter.                                |
//+------------------------------------------------------------------+
double CSignalTrend::Direction(void)
  {
   int idx   =StartIndex();
//---
   double m0 = GetIndicatorValue(m_ptr,idx);
   double m1 == GetIndicatorValue(m_ptr,idx+1);
   
   if (m)
//--- condition OK
   return(0.0);
  }
//+------------------------------------------------------------------+
