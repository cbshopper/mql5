//+------------------------------------------------------------------+
//|                                                  TrailingHMA.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertTrailing.mqh>
#include <CB\CBiHull.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Trailing Stop based on MA                                  |
//| Type=Trailing                                                    |
//| Name=HMA                                                          |
//| Class=CTrailingMA                                                |
//| Page=                                                            |
//| Parameter=Period,int,12,Period of MA                             |
//| Parameter=Shift,int,0,Shift of MA                                |
//| Parameter=Method,ENUM_MA_METHOD,MODE_SMA,Method of averaging     |
//| Parameter=Applied,ENUM_APPLIED_PRICE,PRICE_CLOSE,Prices series   |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CTrailingMA.                                               |
//| Purpose: Class of trailing stops based on MA.                    |
//|              Derives from class CExpertTrailing.                 |
//+------------------------------------------------------------------+
class CTrailingHMA : public CExpertTrailing
  {
protected:
   CiHull             *m_MA;
   //--- input parameters
   int               m_ma_period;
   int               m_ma_shift;
   double               m_ma_divisor;
   ENUM_APPLIED_PRICE m_ma_applied;
   double            m_filter;

public:
                     CTrailingHMA(void);
                    ~CTrailingHMA(void);
   //--- methods of initialization of protected data
   void              Period(int period)                  { m_ma_period=period;   }
   void              Shift(int value)                  { m_ma_shift=value;   }
   void              Filter(int value)                  { m_filter=value;   }
  // void              Divisor(double divisor)                    { m_ma_divisor=divisor;     }
   void              Applied(ENUM_APPLIED_PRICE applied) { m_ma_applied=applied; }
   virtual bool      InitIndicators(CIndicators *indicators);
   virtual bool      ValidationSettings(void);
   //---
   virtual bool      CheckTrailingStopLong(CPositionInfo *position,double &sl,double &tp);
   virtual bool      CheckTrailingStopShort(CPositionInfo *position,double &sl,double &tp);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CTrailingHMA::CTrailingHMA(void) : m_MA(NULL),
                                      m_ma_period(12),
                                      m_ma_divisor(2.0),
                                      m_ma_applied(PRICE_CLOSE),
                                      m_ma_shift(0),
                                      m_filter(0)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
void CTrailingHMA::~CTrailingHMA(void)
  {
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool CTrailingHMA::ValidationSettings(void)
  {
   if(!CExpertTrailing::ValidationSettings())
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
//| Checking for input parameters and setting protected data.        |
//+------------------------------------------------------------------+
bool CTrailingHMA::InitIndicators(CIndicators *indicators)
  {
//--- check
   if(indicators==NULL)
      return(false);
//--- create MA indicator
   if(m_MA==NULL)
      if((m_MA=new CiHull)==NULL)
        {
         printf(__FUNCTION__+": error creating object");
         return(false);
        }
       
//--- add MA indicator to collection
   if(!indicators.Add(m_MA))
     {
      printf(__FUNCTION__+": error adding object");
      delete m_MA;
      return(false);
     }
     
//--- initialize object
   if(!m_MA.Create(m_symbol.Name(),m_period,m_ma_period,m_ma_shift,m_ma_applied,m_filter))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//--- ok
   return(true);
  }
  
 /*
//+------------------------------------------------------------------+
//| Checking trailing stop and/or profit for long position.          |
//+------------------------------------------------------------------+
bool CTrailingHMA::CheckTrailingStopLong(CPositionInfo *position,double &sl,double &tp)
  {
//--- check
   if(position==NULL)
      return(false);
//---
   double level =NormalizeDouble(m_symbol.Bid()-m_symbol.StopsLevel()*m_symbol.Point(),m_symbol.Digits());
   double new_sl=NormalizeDouble(m_MA.calculate(1),m_symbol.Digits());
   double pos_sl=position.StopLoss();
   double base  =(pos_sl==0.0) ? position.PriceOpen() : pos_sl;
//---
   sl=EMPTY_VALUE;
   tp=EMPTY_VALUE;
   if(new_sl>base && new_sl<level)
      sl=new_sl;
//---
   return(sl!=EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
//| Checking trailing stop and/or profit for short position.         |
//+------------------------------------------------------------------+
bool CTrailingHMA::CheckTrailingStopShort(CPositionInfo *position,double &sl,double &tp)
  {
//--- check
   if(position==NULL)
      return(false);
//---
   double level =NormalizeDouble(m_symbol.Ask()+m_symbol.StopsLevel()*m_symbol.Point(),m_symbol.Digits());
   double new_sl=NormalizeDouble(m_MA.calculate(1)+m_symbol.Spread()*m_symbol.Point(),m_symbol.Digits());
   double pos_sl=position.StopLoss();
   double base  =(pos_sl==0.0) ? position.PriceOpen() : pos_sl;
//---
   sl=EMPTY_VALUE;
   tp=EMPTY_VALUE;
   if(new_sl<base && new_sl>level)
      sl=new_sl;
//---
   return(sl!=EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
*/
//+------------------------------------------------------------------+
//| Checking trailing stop and/or profit for long position.          |
//+------------------------------------------------------------------+
bool CTrailingHMA::CheckTrailingStopLong(CPositionInfo *position,double &sl,double &tp)
  {
//--- check
   if(position==NULL)
      return(false);
//---
   sl=EMPTY_VALUE;
   tp=EMPTY_VALUE;
double win = position.Profit();
   double price =NormalizeDouble(m_symbol.Bid(),m_symbol.Digits());
   double level =NormalizeDouble(m_symbol.Bid()-m_symbol.StopsLevel()*m_symbol.Point(),m_symbol.Digits());
   double new_sl=NormalizeDouble(m_MA.Main(1),m_symbol.Digits());
   double pos_sl=position.StopLoss();
   double base  =(pos_sl==0.0) ? position.PriceOpen() : pos_sl;
//---
   //if(new_sl>base && new_sl<level)
   //   sl=new_sl;
 //---     
      double ma0 = m_MA.Main(1);
   double ma1 =m_MA.Main(2);
   double ma2 =m_MA.Main(3);
   bool turndn = ma2 < ma1 && ma0 < ma1;
   if (turndn) sl = level;
 
//---
   return(sl!=EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
//| Checking trailing stop and/or profit for short position.         |
//+------------------------------------------------------------------+
bool CTrailingHMA::CheckTrailingStopShort(CPositionInfo *position,double &sl,double &tp)
  {
//--- check
   if(position==NULL)
      return(false);
//---
   sl=EMPTY_VALUE;
   tp=EMPTY_VALUE;
   double win = position.Profit();
   double price =NormalizeDouble(m_symbol.Bid(),m_symbol.Digits());
   double level =NormalizeDouble(m_symbol.Ask()+m_symbol.StopsLevel()*m_symbol.Point(),m_symbol.Digits());
   double new_sl=NormalizeDouble(m_MA.Main(1)+m_symbol.Spread()*m_symbol.Point(),m_symbol.Digits());
   double pos_sl=position.StopLoss();
   double base  =(pos_sl==0.0) ? position.PriceOpen() : pos_sl;
//---
  // if(new_sl<base && new_sl>level)
  //    sl=new_sl;
//---
   double ma0 = m_MA.Main(1);
   double ma1 =m_MA.Main(2);
   double ma2 =m_MA.Main(3);
   bool turnup = ma2 > ma1 && ma0 > ma1;
   if (turnup) sl = level;
   return(sl!=EMPTY_VALUE);
  }
//+------------------------------------------------------------------+