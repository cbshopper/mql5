//+------------------------------------------------------------------+
//|                                                     SignalMA.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals of indicator 'Moving Average Crossing'             |
//| Type=SignalAdvanced                                              |
//| Name=Moving Average Cross                                        |
//| ShortName=MACross                                                |
//| Class=CSignalMACross                                             |
//| Page=signal_ma                                                   |
//| Parameter=PeriodMA,int,12,Period of averaging                    |
//| Parameter=MinHigh,int,0,Minimum Bar High-Low-Diff             |
//| Parameter=Method,ENUM_MA_METHOD,MODE_SMA,Method of averaging     |
//| Parameter=Applied,ENUM_APPLIED_PRICE,PRICE_CLOSE,Prices series   |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalMACross.                                                 |
//| Purpose: Class of generator of trade signals based on            |
//|          the 'Moving Average' indicator.                         |
//| Is derived from the CExpertSignal class.                         |
//+------------------------------------------------------------------+
class CSignalMACross : public CExpertSignal
  {
protected:
   CiMA              m_ma;             // object-indicator
   //--- adjusted parameters
   int               m_ma_period;      // the "period of averaging" parameter of the indicator
   int               m_minhigh;       // the "time shift" parameter of the indicator
   ENUM_MA_METHOD    m_ma_method;      // the "method of averaging" parameter of the indicator
   ENUM_APPLIED_PRICE m_ma_applied;    // the "object of averaging" parameter of the indicator
   //--- "weights" of market models (0-100)
   int               m_pattern_0;      // model 0 "price is on the necessary side from the indicator"

public:
                     CSignalMACross(void);
                    ~CSignalMACross(void);
   //--- methods of setting adjustable parameters
   void              PeriodMA(int value)                 { m_ma_period=value;          }
   void              MinHigh(int value)                    { m_minhigh=value;           }
   void              Method(ENUM_MA_METHOD value)        { m_ma_method=value;          }
   void              Applied(ENUM_APPLIED_PRICE value)   { m_ma_applied=value;         }
   //--- methods of adjusting "weights" of market models
   void              Pattern_0(int value)                { m_pattern_0=value;          }
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
   double            MA(int ind)                         { return(m_ma.Main(ind));     }
   double            DiffMA(int ind)                     { return(MA(ind)-MA(ind+1));  }
   double            DiffOpenMA(int ind)                 { return(Open(ind)-MA(ind));  }
   double            DiffHighMA(int ind)                 { return(High(ind)-MA(ind));  }
   double            DiffLowMA(int ind)                  { return(Low(ind)-MA(ind));   }
   double            DiffCloseMA(int ind)                { return(Close(ind)-MA(ind)); }
   double            BarHigh(int ind)                    { return(High(ind)-Low(ind)); }
   bool				 CrossUp(int ind)				     { return(Close(ind) > MA(ind) && Open(ind) < MA(ind));}
   bool				 CrossDn(int ind)				     { return(Close(ind) < MA(ind) && Open(ind) > MA(ind));}
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalMACross::CSignalMACross(void) : m_ma_period(12),
                             m_minhigh(1),
                             m_ma_method(MODE_SMA),
                             m_ma_applied(PRICE_CLOSE),
                             m_pattern_0(80)
  {
//--- initialization of protected data
   m_used_series=USE_SERIES_OPEN+USE_SERIES_HIGH+USE_SERIES_LOW+USE_SERIES_CLOSE;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalMACross::~CSignalMACross(void)
  {
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool CSignalMACross::ValidationSettings(void)
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
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//| Create indicators.                                               |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
bool CSignalMACross::InitIndicators(CIndicators *indicators)
  {
//+++ check pointer
   if(indicators==NULL)
      return(false);
//+++ initialization of indicators and timeseries of additional filters
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//+++ create and initialize MA indicator
   if(!InitMA(indicators))
      return(false);
//+++ ok
   return(true);
  }
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//| Initialize MA indicators.                                        |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
bool CSignalMACross::InitMA(CIndicators *indicators)
  {
//+++ check pointer
   if(indicators==NULL)
      return(false);
//+++ add object to collection
   if(!indicators.Add(GetPointer(m_ma)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- initialize object
     if(!m_ma.Create(m_symbol.Name(),m_period,m_ma_period,0,m_ma_method,m_ma_applied))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//+++ ok
   return(true);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignalMACross::LongCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
//--- analyze positional relationship of the close price and the indicator at the first analyzed bar
    if (CrossUp(idx) && BarHigh(idx) > m_minhigh * Point())
	{
	  result = m_pattern_0;
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignalMACross::ShortCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
//--- analyze positional relationship of the close price and the indicator at the first analyzed bar
    if (CrossDn(idx) && (BarHigh(idx) > m_minhigh * Point()))
	{
	  result = m_pattern_0;
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
