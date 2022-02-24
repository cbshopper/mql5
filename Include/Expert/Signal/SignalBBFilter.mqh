//+------------------------------------------------------------------+
//|                                                    SignalTrendF.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
#define SELL_FORBIDDEN 9999
#define BUY_FORBIDDEN -9999
#define TRADE_FORBIDDEN -11111111
#define IGNORE_ME -88888888

// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals Bollinger Bands Filter                             |
//| Type=SignalAdvanced                                              |
//| Name=SignalBollingerFilter                                       |
//| ShortName=BBF                                                    |
//| Class=CSignalBBFilter                                            |
//| Page=signal_bb_filter                                            |
//| Parameter=BBFPeriod,int,14,BB Period                              |
//| Parameter=BBFPrice,ENUM_APPLIED_PRICE,PRICE_MEDIAN, BB Price      |
//| Parameter=BBFDeviation,double,1.5, BB Deviation                   |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalTrendF                                              |
//| Appointment: Class trading signals trend filter.                 |
//|              Derives from class CExpertSignal.                   |
//+------------------------------------------------------------------+
class CSignalBBFilter : public CExpertSignal
  {
protected:
   //--- input parameters
   int                  bb_period;
   ENUM_APPLIED_PRICE    bb_price;
   double               bb_deviation;
   //int               bb_ptr;
   CiBands             iBB;

public:
                     CSignalBBFilter(void);
                    ~CSignalBBFilter(void);
   //--- methods initialize protected data
   void              BBFPeriod(int value)  { bb_period=value; }
   void              BBFPrice(ENUM_APPLIED_PRICE value)  { bb_price=value; }
   void              BBFDeviation(double value)     { bb_deviation=value;    }
   
   
protected:   
      //--- method of verification of settings
   virtual bool      ValidationSettings(void);
   //--- method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators *indicators);
   //--- method of initialization of the indicator
   bool              InitBB(CIndicators *indicators);
   //--- methods of checking conditions of entering the market
  virtual double    Direction(void);
  virtual double    DirectionX(void) { return Direction(); }
   //+++ methods of checking if the market models are formed
   //virtual int       LongCondition(void);
   //virtual int       ShortCondition(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalBBFilter::CSignalBBFilter(void) : bb_period(50),
                               bb_price(PRICE_MEDIAN),
                               bb_deviation(1.5)
  {
    
  
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalBBFilter::~CSignalBBFilter(void)
  {
     
  }
  
  //+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool CSignalBBFilter::ValidationSettings(void)
  {
//--- call of the method of the parent class
   if(!CExpertSignal::ValidationSettings())
      return(false);
   if (bb_deviation == 0  || bb_period==0)
    return false;   
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//+------------------------------------------------------------------+
bool CSignalBBFilter::InitIndicators(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- initialization of indicators and timeseries of additional filters
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//--- create and initialize SAR indicator
   if(!InitBB(indicators))
      return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create SAR indicators.                                           |
//+------------------------------------------------------------------+
bool CSignalBBFilter::InitBB(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- add object to collection
   if(!indicators.Add(GetPointer(iBB)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- initialize object
   //  bb_ptr=iBands(m_symbol.Name(),NULL,bb_period,0,bb_deviation,bb_price);
   if (!iBB.Create(m_symbol.Name(),NULL,bb_period,0,bb_deviation,bb_price))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//--- ok
   return(true);
  }
  
  
  
//+------------------------------------------------------------------+
//| Check conditions for time filter.                                |
//+------------------------------------------------------------------+
double CSignalBBFilter::Direction(void)
  {
  Print(__FUNCTION__,"********************************* ");

   int idx   =StartIndex();
//---
   double bbupper = iBB.Upper(idx);
   double bblower = iBB.Lower(idx);
   double ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK); 
   double bid=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
   
   //Print(__FUNCTION__,": SELL_FORBIDDEN=",ask < bblower, " BUY_FORBIDDEN=",bid > bbupper);
   //if (bid < bblower || bid > bbupper ) return (SELL_FORBIDDEN); 
   //if (ask > bbupper  || ask < bblower) return (BUY_FORBIDDEN) ;
   
   if (bid < bblower || bid > bbupper) return (TRADE_FORBIDDEN) ;
//--- condition OK
   return(IGNORE_ME);
  }
 
//+------------------------------------------------------------------+
/*
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//| "Voting" that price will grow.                                   |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
int CSignalBBFilter::LongCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
   double m0 = GetIndicatorValue(bb_ptr,idx);
   double m1 = GetIndicatorValue(bb_ptr,idx+1);
   if (m0 < m1  ) result = TREND_DN; //--- the "prohibition" signal
 //  result = EMPTY_VALUE;
 //  Print(__FUNCTION__," Result=",result);
//+++ return the result
   return(result);
  }
  
  
int CSignalBBFilter::ShortCondition(void)
  {
    int result=0;
   int idx   =StartIndex();
   double m0 = GetIndicatorValue(bb_ptr,idx);
   double m1 = GetIndicatorValue(bb_ptr,idx+1);
  if (m0 > m1  ) result = TREND_UP; //--- the "prohibition" signal
//  result = EMPTY_VALUE;
//   Print(__FUNCTION__," Result=",result);
//+++ return the result
   return(result);
  }
*/