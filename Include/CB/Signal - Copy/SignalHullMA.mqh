//+------------------------------------------------------------------+
//|                                                     SignalMA.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
#include "..\..\..\Indicators\CB\ma\hullMA.mqh"
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals of indicator 'Moving Average'                      |
//| Type=SignalAdvanced                                              |
//| Name=Moving Average                                              |
//| ShortName=MA                                                     |
//| Class=CSignalMA                                                  |
//| Page=signal_ma                                                   |
//| Parameter=PeriodMA,int,12,Period of averaging                    |
//| Parameter=Divisior, int,2, Hull Divisor     |
//| Parameter=Applied,ENUM_APPLIED_PRICE,PRICE_CLOSE,Prices series   |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalHullMA.                                             |
//| Purpose: Class of generator of trade signals based on            |
//|          the 'Hull Moving Average' indicator.                    |
//| Is derived from the CExpertSignal class.                         |
//+------------------------------------------------------------------+
class CSignalMA : public CExpertSignal
  {
protected:
   CHull              m_ma;             // object-indicator
   //--- adjusted parameters
   int               m_ma_period;      // the "period of averaging" parameter of the indicator
 //  int               m_ma_shift;       // the "time shift" parameter of the indicator
 //  ENUM_MA_METHOD    m_ma_method;      // the "method of averaging" parameter of the indicator
   double             m_ma_divisor;
   ENUM_APPLIED_PRICE m_ma_applied;    // the "object of averaging" parameter of the indicator
 //  double            m_ma_factor;
   //--- "weights" of market models (0-100)
   int               m_pattern_0;      // model 0 "price is on the necessary side from the indicator"
   int               m_pattern_1;      // model 1 "price crossed the indicator with opposite direction"
   int               m_pattern_2;      // model 2 "price crossed the indicator with the same direction"
   int               m_pattern_3;      // model 3 "piercing"

public:
                     CSignalMA(void);
                    ~CSignalMA(void);
   //--- methods of setting adjustable parameters
   void              PeriodMA(int value)                 { m_ma_period=value;          }
//   void              Shift(int value)                    { m_ma_shift=value;           }
//   void              Method(ENUM_MA_METHOD value)        { m_ma_method=value;          }
//   void              Applied(ENUM_APPLIED_PRICE value)   { m_ma_applied=value;         }
   //--- methods of adjusting "weights" of market models
   void              Pattern_0(int value)                { m_pattern_0=value;          }
   void              Pattern_1(int value)                { m_pattern_1=value;          }
   void              Pattern_2(int value)                { m_pattern_2=value;          }
   void              Pattern_3(int value)                { m_pattern_3=value;          }
   //--- method of verification of settings
   virtual bool      ValidationSettings(void);
   //--- method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators *indicators);
   //--- methods of checking if the market models are formed
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);

protected:
   //--- method of initialization of the indicator
   bool              InitMA(CIndicators *indicators);
   //--- methods of getting data
   double            MA(int ind)                         { return(m_ma.calculate(ind));     }
   bool            TurnUp(int ind)                   { return(MA(ind-2)>MA(ind+1) && MA(ind)>MA(ind+1));  }
   bool            TurnDown(int ind)                 { return(MA(ind-2)<MA(ind+1) && MA(ind)<MA(ind+1));  }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalMA::CSignalMA(void) : m_ma_period(12),
                            // m_ma_shift(0),
                            // m_ma_method(MODE_SMA),
                             m_ma_divisor(2.0),
                             m_ma_applied(PRICE_CLOSE),
                             m_pattern_0(80),
                             m_pattern_1(10),
                             m_pattern_2(60),
                             m_pattern_3(60)
  {
//--- initialization of protected data
   m_used_series=USE_SERIES_OPEN+USE_SERIES_HIGH+USE_SERIES_LOW+USE_SERIES_CLOSE;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalMA::~CSignalMA(void)
  {
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool CSignalMA::ValidationSettings(void)
  {
//--- validation settings of additional filters
   if(!CExpertSignal::ValidationSettings())
      return(false);
//--- initial data checks
   if(m_ma_period<=0)
     {
      printf(__FUNCTION__+": period MA must be greater than 0");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//+------------------------------------------------------------------+
bool CSignalMA::InitIndicators(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- initialization of indicators and timeseries of additional filters
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//--- create and initialize MA indicator
   if(!InitMA(indicators))
      return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize MA indicators.                                        |
//+------------------------------------------------------------------+
bool CSignalMA::InitMA(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- add object to collection
   m_ma.init(m_ma_period,m_ma_divisor,m_ma_applied);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignalMA::LongCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
//--- analyze positional relationship of the close price and the indicator at the first analyzed bar
   if(TurnUp(idx))
     {
        //--- the open price is above the indicator (i.e. there was an intersection), but the indicator is directed upwards
         result=m_pattern_1;
         //--- consider that this is an unformed "piercing" and suggest to enter the market at the current price
         m_base_price=0.0;
     }

//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignalMA::ShortCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
//--- analyze positional relationship of the close price and the indicator at the first analyzed bar
   if(TurnDown(idx))
     {
      //--- the close price is above the indicator
         //--- the open price is below the indicator (i.e. there was an intersection), but the indicator is directed downwards
         result=m_pattern_1;
         //--- consider that this is an unformed "piercing" and suggest to enter the market at the current price
         m_base_price=0.0;
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
