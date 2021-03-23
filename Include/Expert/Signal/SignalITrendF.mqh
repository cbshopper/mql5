//+------------------------------------------------------------------+
//|                                                    SignalTrendF.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
#include <CB\CB_IndicatorHelper.mqh>
#define TREND_UP 9999
#define TREND_DN -9999
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals tend filter                                        |
//| Type=SignalAdvanced                                              |
//| Name=SignalTrendFilter                                           |
//| ShortName=STF                                                    |
//| Class=CSignalTrend                                                 |
//| Page=signal_trend_filter                                         |
//| Parameter=TrendPeriod,int,50,Trend Period                             |
//| Parameter=TrendMethod,ENUM_MA_METHOD,MODE_SMA,Method of averaging     |
//| Parameter=TrendMindiff,int,0,Trend Period min.Diff                    |
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
   int               trend_period;
   ENUM_MA_METHOD    trend_method;
   int               trend_mindiff;
   int               trend_ptr;

public:
                     CSignalTrend(void);
                    ~CSignalTrend(void);
   //--- methods initialize protected data
   void              TrendPeriod(int value)  { trend_period=value; }
//    void             TrendMethod(int value)  { trend_method=value; }
   void              TrendMindiff(int value)     { trend_mindiff=value;    }
   //--- methods of checking conditions of entering the market
  virtual double    Direction(void);
   //+++ methods of checking if the market models are formed
   //virtual int       LongCondition(void);
   //virtual int       ShortCondition(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalTrend::CSignalTrend(void) : trend_period(50),
 //                              trend_method(MODE_EMA),
                               trend_mindiff(0),
                               trend_ptr(INVALID_HANDLE)
  {
    
   // trend_ptr=iTriX(NULL,m_period,trend_period,PRICE_CLOSE);
     trend_ptr=iMA(NULL,m_period,trend_period,0,MODE_EMA,PRICE_CLOSE);
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
   double m0 = GetIndicatorValue(trend_ptr,idx);
   double m1 = GetIndicatorValue(trend_ptr,idx+1);
   
   if (m0 > m1) return (TREND_UP); 
   if (m0 < m1  ) return (TREND_DN) ;
//--- condition OK
   return(0.0);
  }
 
//+------------------------------------------------------------------+
/*
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//| "Voting" that price will grow.                                   |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
int CSignalTrend::LongCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
   double m0 = GetIndicatorValue(trend_ptr,idx);
   double m1 = GetIndicatorValue(trend_ptr,idx+1);
   if (m0 < m1  ) result = TREND_DN; //--- the "prohibition" signal
 //  result = EMPTY_VALUE;
 //  Print(__FUNCTION__," Result=",result);
//+++ return the result
   return(result);
  }
  
  
int CSignalTrend::ShortCondition(void)
  {
    int result=0;
   int idx   =StartIndex();
   double m0 = GetIndicatorValue(trend_ptr,idx);
   double m1 = GetIndicatorValue(trend_ptr,idx+1);
  if (m0 > m1  ) result = TREND_UP; //--- the "prohibition" signal
//  result = EMPTY_VALUE;
//   Print(__FUNCTION__," Result=",result);
//+++ return the result
   return(result);
  }
*/