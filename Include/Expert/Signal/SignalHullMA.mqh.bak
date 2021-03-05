//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                                                 SignalHullMA.mqh |
//|                   Copyright 2009+2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#include <Expert\ExpertSignal.mqh>
#include "..\..\..\Indicators\CB\ma\hullMA.mqh"
// wizard description start
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//| Description of the class                                         |
//| Title=Signals of indicator 'Hull Moving Average Turn'            |
//| Type=SignalAdvanced                                              |
//| Name=Hull Moving Average Turn                                    |
//| ShortName=HullMA                                                 |
//| Class=CSignalHullMA                                              |
//| Page=signal_ma                                                   |
//| Parameter=PeriodMA,int,12,Period of averaging                    |
//| Parameter=Divisor, double,2.0, Hull Divisor                      |
//| Parameter=Applied,ENUM_APPLIED_PRICE,PRICE_CLOSE,Prices series   |
//+------------------------------------------------------------------+
// wizard description end
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//| Class CSignalHullMA.                                             |
//| Purpose: Class of generator of trade signals based on            |
//|          the 'Hull Moving Average' indicator.                    |
//| Is derived from the CExpertSignal class.                         |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
class CSignalHullMA : public CExpertSignal
  {
protected:
   CHull              m_ma;             // object+indicator
   //+++ adjusted parameters
   int               m_ma_period;      // the "period of averaging" parameter of the indicator
   //  int               m_ma_shift;       // the "time shift" parameter of the indicator
   //  ENUM_MA_METHOD    m_ma_method;      // the "method of averaging" parameter of the indicator
   double             m_ma_divisor;
   ENUM_APPLIED_PRICE m_ma_applied;    // the "object of averaging" parameter of the indicator
   //  double            m_ma_factor;
   //+++ "weights" of market models (0+100)
   int               m_pattern_0;      // model 0 "MA turns"

public:
                     CSignalHullMA(void);
                    ~CSignalHullMA(void);
   //+++ methods of setting adjustable parameters
   void              PeriodMA(int value)                 { m_ma_period=value;          }
   void              Applied(ENUM_APPLIED_PRICE value)   { m_ma_applied=value;         }
   void              Divisor(double value)               { m_ma_divisor=value;         }
   //+++ methods of adjusting "weights" of market models
   void              Pattern_0(int value)                { m_pattern_0=value;          }
   //+++ method of verification of settings
   virtual bool      ValidationSettings(void);
   //+++ method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators *indicators);
   //+++ methods of checking if the market models are formed
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);

protected:
   //+++ method of initialization of the indicator
   bool              InitMA(CIndicators *indicators);
   //+++ methods of getting data
   double            MA(int ind)                         { return(m_ma.calculate(ind));     }
   //  bool              TurnUp(int ind)                   {Print(__FUNCTION__," ;MA(ind)=",MA(ind),"MA(ind+1)=",MA(ind+1),"MA(ind+2)=",MA(ind+2)); return(MA(ind+2)>MA(ind+1) && MA(ind)>MA(ind+1));  }
   //  bool              TurnDown(int ind)                 {Print(__FUNCTION__," ;MA(ind)=",MA(ind),"MA(ind+1)=",MA(ind+1),"MA(ind+2)=",MA(ind+2)); return(MA(ind+2)<MA(ind+1) && MA(ind)<MA(ind+1));  }
   bool              TurnUp(int ind)
     {
     
     // Print(__FUNCTION__," ;MA(ind)=",MA(ind));
      bool ret = MA(ind+2)>MA(ind+1) && MA(ind)>MA(ind+1); // && MA(ind) >= MA(ind+2);
     if (ret) 
       DrawDot("BUY!",ind,MA(ind),clrBlue,116,1);
      return(ret) ;
     }
   bool              TurnDown(int ind)
     {
      
   //   Print(__FUNCTION__," ;MA(ind)=",MA(ind));
      bool ret = MA(ind+2)<MA(ind+1) && MA(ind)<MA(ind+1); // && MA(ind) <= MA(ind+2);
       if (ret) 
        DrawDot("SELL!",ind,MA(ind),clrRed,116,1);
      return(ret);
     }
   void              DrawDot(string name, int shift, double price, color clr = clrBlue, int code = 159, int width = 1);
  };
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//| Constructor                                                      |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CSignalHullMA::CSignalHullMA(void) : m_ma_period(12),
// m_ma_shift(0),
// m_ma_method(MODE_SMA),
   m_ma_divisor(2.0),
   m_ma_applied(PRICE_CLOSE),
   m_pattern_0(100)
  {
//+++ initialization of protected data
   m_used_series=USE_SERIES_OPEN+USE_SERIES_HIGH+USE_SERIES_LOW+USE_SERIES_CLOSE;
  }
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//| Destructor                                                       |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CSignalHullMA::~CSignalHullMA(void)
  {
  }
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//| Validation settings protected data.                              |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
bool CSignalHullMA::ValidationSettings(void)
  {
//+++ validation settings of additional filters
   if(!CExpertSignal::ValidationSettings())
      return(false);
//+++ initial data checks
   if(m_ma_period<=0)
     {
      printf(__FUNCTION__+": period MA must be greater than 0");
      return(false);
     }
//+++ ok
   return(true);
  }
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//| Create indicators.                                               |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
bool CSignalHullMA::InitIndicators(CIndicators *indicators)
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
bool CSignalHullMA::InitMA(CIndicators *indicators)
  {
//+++ check pointer
   if(indicators==NULL)
      return(false);
//+++ add object to collection
   m_ma.init(m_ma_period,m_ma_divisor,m_ma_applied);
//+++ ok
   return(true);
  }
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//| "Voting" that price will grow.                                   |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
int CSignalHullMA::LongCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
//  Print(__FUNCTION__, ": idx=",idx);
//+++ analyze positional relationship of the close price and the indicator at the first analyzed bar
   if(TurnUp(idx))
     {

      //+++ the open price is above the indicator (i.e. there was an intersection), but the indicator is directed upwards
      result=m_pattern_0;
      //+++ consider that this is an unformed "piercing" and suggest to enter the market at the current price
      m_base_price=0.0;

      Print(__FUNCTION__, ": result=",result);
     }

//+++ return the result
   return(result);
  }
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//| "Voting" that price will fall.                                   |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
int CSignalHullMA::ShortCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
//  Print(__FUNCTION__, ": idx=",idx);
//+++ analyze positional relationship of the close price and the indicator at the first analyzed bar
   if(TurnDown(idx))
     {
      //+++ the close price is above the indicator
      //+++ the open price is below the indicator (i.e. there was an intersection), but the indicator is directed downwards
      result=m_pattern_0;
      //+++ consider that this is an unformed "piercing" and suggest to enter the market at the current price
      m_base_price=0.0;
      Print(__FUNCTION__, ": result=",result);
     }
//+++ return the result
   return(result);
  }
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSignalHullMA:: DrawDot(string name, int shift, double price, color clr = clrBlue, int code = 159, int width = 1)
  {
//   if(Bars(NULL,0) - 1 < shift)
//      return;
// print(__FUNCTION__,"Bars(NULL,0)="+ Bars(NULL,0));
   string EMAName = name + (string)iTime(NULL,0,shift);

   if(ObjectFind(0,EMAName) == -1)
     {
      ObjectDelete(0,EMAName);
     }
   if(ObjectCreate(0, EMAName, OBJ_ARROW, 0, 0,0))
     {
      ObjectSetInteger(0, EMAName, OBJPROP_ARROWCODE, (uchar)code);
      ObjectSetInteger(0,EMAName, OBJPROP_WIDTH, width);
      ObjectSetInteger(0, EMAName, OBJPROP_COLOR, clr);
       ObjectSetDouble(0,EMAName,OBJPROP_PRICE,price);// Set price
       ObjectSetInteger(0,EMAName,OBJPROP_TIME,iTime(NULL, 0, shift));   
      ChartRedraw(0);                                        // Draw arrow now
      Print(__FUNCTION__," EMAName="+EMAName, " Price=",price);
     }
  }
//+------------------------------------------------------------------+
