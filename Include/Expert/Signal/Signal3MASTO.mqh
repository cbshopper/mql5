//+------------------------------------------------------------------+
//|                                                     SignalMA.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals of indicator '3MA (3EMA) + STO'                    |
//| Type=SignalAdvanced                                              |
//| Name=3MA                                                        |
//| ShortName=3EMA                                                     |
//| Class=CSignal3MASTO                                                 |
//| Page=signal_ma                                                   |
//| Parameter=Period0,int,21,Period of averaging 0                   |
//| Parameter=Period1,int,34,Period of averaging 1                   |
//| Parameter=Period2,int,50,Period of averaging 2                   |
//| Parameter=Method,ENUM_MA_METHOD,MODE_SMA,Method of averaging     |
//| Parameter=Applied,ENUM_APPLIED_PRICE,PRICE_CLOSE,Prices series   |
//| Parameter=Offset,int,3,Shift Offset of previous MA  |
//| Parameter=UseMACross,bool,false,Use Cross of MA2 as Signal   |
//| Parameter=MinDiff,int,1,min. Diff of MA2  |

//| Parameter=UseStoSignal,bool,false,use STO-Signal additional  |
//| Parameter=StoK,int,5,Sto K-Period  |
//| Parameter=StoD,int,5,Sto D-Period |
//| Parameter=StoSlowing,int,3,Sto Slowing  |
//| Parameter=StoLevel,int,20, STO Level  |

//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignal3MASTO.                                                 |
//| Purpose: Class of generator of trade signals based on            |
//|          the 'Moving Average' indicator.                         |
//| Is derived from the CExpertSignal class.                         |
//+------------------------------------------------------------------+
class CSignal3MASTO : public CExpertSignal
  {
protected:
   CiMA              m_ma0;             // object-indicator
   CiMA              m_ma1;             // object-indicator
   CiMA              m_ma2;             // object-indicator
   CiStochastic      m_stoch;             // object Stochastic Indicator
   int               m_offset;
   int               m_minDiff;
   bool              m_useMACross;
   bool              m_useStoSignal;
   int               m_periodK;
   int               m_periodD;
   int               m_period_slow;
   int               m_StoLevel;
   ENUM_STO_PRICE    m_applied;        // the "apply to" parameter of the oscillator
   //--- adjusted parameters
   int               m_ma_period0;      // the "period of averaging" parameter of the indicator
   int               m_ma_period1;      // the "period of averaging" parameter of the indicator
   int               m_ma_period2;      // the "period of averaging" parameter of the indicator
   ENUM_MA_METHOD    m_ma_method;      // the "method of averaging" parameter of the indicator
   ENUM_APPLIED_PRICE m_ma_applied;    // the "object of averaging" parameter of the indicator
   //--- "weights" of market models (0-100)
   int               m_pattern_0;      // model 0 "price is on the necessary side from the indicator"

public:
                     CSignal3MASTO(void);
                    ~CSignal3MASTO(void);
   //--- methods of setting adjustable parameters
   void              Period0(int value)                  { m_ma_period0=value;          }
   void              Period1(int value)                  { m_ma_period1=value;          }
   void              Period2(int value)                  { m_ma_period2=value;          }
   void              Method(ENUM_MA_METHOD value)        { m_ma_method=value;          }
   void              Applied(ENUM_APPLIED_PRICE value)   { m_offset=value;         }
   void              Offset(int value)                   { m_ma_applied=value;         }
   void              UseMACross(bool value)              { m_useMACross=value;         }
   void              MinDiff(int value)                  { m_minDiff=value;         }
   void              UseStoSignal(bool value)            { m_useStoSignal=value;         }
   void              StoK(int value)                     { m_periodK=value;         }
   void              StoD(int value)                     { m_periodD=value;         }
   void              StoSlowing(int value)               { m_period_slow=value;         }
   void              StoLevel(int value)                 { m_StoLevel=value;         }




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
   bool              InitStoch(CIndicators *indicators);
   //--- methods of getting data
   double            MA0(int ind)                         { return(m_ma0.Main(ind));     }
   double            MA1(int ind)                         { return(m_ma1.Main(ind));     }
   double            MA2(int ind)                         { return(m_ma2.Main(ind));     }
   double            STOVal(int ind)                        { return(m_stoch.Main(ind));     }
   double            STOSig(int ind)                        { return(m_stoch.Signal(ind));     }

   double            DiffMA0(int ind)                     { return(MA0(ind)-MA0(ind+1));  }
   double            DiffMA1(int ind)                     { return(MA1(ind)-MA1(ind+1));  }
   double            DiffMA2(int ind)                     { return(MA2(ind)-MA2(ind+1));  }

   bool              DirectionUp(int ind)                  { return (MA0(ind) > MA1(ind) && MA1(ind) > MA2(ind));}
   bool              DirectionDn(int ind)                  { return (MA0(ind) < MA1(ind) && MA1(ind) < MA2(ind));}

   double            DiffOpenMA0(int ind)                 { return(Open(ind)-MA0(ind));  }
   double            DiffHighMA0(int ind)                 { return(High(ind)-MA0(ind));  }
   double            DiffLowMA0(int ind)                  { return(Low(ind)-MA0(ind));   }
   double            DiffCloseMA0(int ind)                { return(Close(ind)-MA0(ind)); }
   int               GetSignal3EMA(int ind);


  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignal3MASTO::CSignal3MASTO(void) : m_ma_period0(21),m_ma_period1(34),m_ma_period2(50),
   m_ma_method(MODE_SMA),
   m_ma_applied(PRICE_CLOSE),
   m_minDiff(1),
   m_offset(2),
   m_useMACross(false),
   m_useStoSignal(false),
   m_periodK(5),
   m_periodD(3),
   m_period_slow(3),
   m_StoLevel(20),
   m_applied(STO_LOWHIGH),        // the "apply to" parameter of the oscillator
   m_pattern_0(80)
  {
//--- initialization of protected data
   m_used_series=USE_SERIES_OPEN+USE_SERIES_HIGH+USE_SERIES_LOW+USE_SERIES_CLOSE;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignal3MASTO::~CSignal3MASTO(void)
  {
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool CSignal3MASTO::ValidationSettings(void)
  {
//--- validation settings of additional filters
   if(!CExpertSignal::ValidationSettings())
      return(false);
//--- initial data checks
   if(m_ma_period0<=0 || m_ma_period1<=0 || m_ma_period2<=0)
     {
      printf(__FUNCTION__+": period MA must be greater than 0");
      return(false);
     }
   if(m_ma_period0>= m_ma_period1 || m_ma_period1>= m_ma_period2 || m_ma_period0>= m_ma_period2)
     {
      printf(__FUNCTION__+": periods of MA must be in growing direction");
      return(false);
     }
   if(m_periodK<=0)
     {
      printf(__FUNCTION__+": the period %K of the Stochastic oscillator must be greater than 0");
      return(false);
     }
   if(m_periodD<=0)
     {
      printf(__FUNCTION__+": the period %D of the Stochastic oscillator must be greater than 0");
      return(false);
     }
//--- ok
   return(true);
  }
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//| Create indicators.                                               |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
bool CSignal3MASTO::InitIndicators(CIndicators *indicators)
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
 //+++ create and initialize Stocj indicator
   if(!InitStoch(indicators))
      return(false);     
//+++ ok
   return(true);
  }
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//| Initialize MA indicators.                                        |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
bool CSignal3MASTO::InitMA(CIndicators *indicators)
  {
   int m_ma_shift=0;
//+++ check pointer
   if(indicators==NULL)
      return(false);
//+++ add object to collection
   if(!indicators.Add(GetPointer(m_ma0)))
     {
      printf(__FUNCTION__+": error adding object 0");
      return(false);
     }
   if(!indicators.Add(GetPointer(m_ma1)))
     {
      printf(__FUNCTION__+": error adding object 1");
      return(false);
     }
   if(!indicators.Add(GetPointer(m_ma2)))
     {
      printf(__FUNCTION__+": error adding object 2");
      return(false);
     }
//--- initialize object
   if(!m_ma0.Create(m_symbol.Name(),m_period,m_ma_period0,m_ma_shift,m_ma_method,m_ma_applied))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
   if(!m_ma1.Create(m_symbol.Name(),m_period,m_ma_period1,m_ma_shift,m_ma_method,m_ma_applied))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
   if(!m_ma2.Create(m_symbol.Name(),m_period,m_ma_period2,m_ma_shift,m_ma_method,m_ma_applied))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }


//+++ ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize Stochastic oscillators.                               |
//+------------------------------------------------------------------+
bool CSignal3MASTO::InitStoch(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- add object to collection
   if(!indicators.Add(GetPointer(m_stoch)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- initialize object
   if(!m_stoch.Create(m_symbol.Name(),m_period,m_periodK,m_periodD,m_period_slow,MODE_SMA,m_applied))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//--- ok
   return(true);
  }
/*
//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignal3MASTO::LongCondition(void)
{
 int result=0;
 int idx   =StartIndex();
//--- analyze positional relationship of the close price and the indicator at the first analyzed bar
 if(DirectionUp(idx))
   {
    if(DiffOpenMA0(idx) < 0 && DiffCloseMA0(idx) > 0)
       result = m_pattern_0;
   }
//--- return the result
 return(result);
}
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignal3MASTO::ShortCondition(void)
{
 int result=0;
 int idx   =StartIndex();
//--- analyze positional relationship of the close price and the indicator at the first analyzed bar
 if(DirectionDn(idx))
   {
    if(DiffOpenMA0(idx)> 0 && DiffCloseMA0(idx) < 0)
       result = m_pattern_0;
   }
//--- return the result
 return(result);
}
*/

//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignal3MASTO::LongCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
   int signal = GetSignal3EMA(idx);
   if(signal > 0)
      result = m_pattern_0;

//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignal3MASTO::ShortCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
   int signal = GetSignal3EMA(idx);
   if(signal < 0)
      result = m_pattern_0;

//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CSignal3MASTO::GetSignal3EMA(int shift)
  {
   int ret = 0;
   
   int i = shift;
   double ma00 = MA0(shift);
   double ma01 = MA0(shift+1);
   double ma0x = MA0(shift+m_offset);
   double ma10 = MA1(shift);
   double ma11 = MA1(shift+1);
   double ma1x = MA1(shift+m_offset);
   double ma20 = MA2(shift);
   double ma21 = MA2(shift+1);
   double ma2x = MA2(shift+m_offset);

   double StoVal0 = STOVal(i);
   double StoSig0 = STOSig(i);
   double StoVal1 = STOVal(i+1);
   double StoSig1 = STOSig(i+1);

   if(m_useMACross)
     {
      if(ma00 > ma10  && ma0x < ma1x && ma00>ma01)     // Kurs kreuzt ma20 von unten nach oben und steigt
         ret= 1;

      if(ma00 < ma10  && ma0x > ma1x && ma00<ma01) //  Kurs kreutz ma20 von oben nach unten und fällt
         ret= -1;
     }

   if(ret==0)
     {
      if(ma21 < ma20 - m_minDiff*Point() && ma00 > ma10 && ma10> ma20)    // steigende Kurse
        {
         if(iLow(NULL,0,i) < ma00 && iHigh(NULL,0,i) > ma00 && iOpen(NULL,0,i) < iClose(NULL,0,i) && (StoVal0 <= 100-m_StoLevel || !m_useStoSignal))   // && iOpen(NULL,0,i) < iClose(NULL,0,i))
            ret=1;
         if(m_useStoSignal)
            if(StoVal1 < StoSig1 && StoVal0 > StoSig0 && StoVal1 <= m_StoLevel)
               ret=1;
        }
     }
   if(ret==0)
     {
      if(ma21 > ma20 + m_minDiff*Point() && ma00 < ma10 && ma10< ma20)       // fallende Kurse
        {
         if(iLow(NULL,0,i) < ma00 && iHigh(NULL,0,i) > ma00 && iOpen(NULL,0,i) > iClose(NULL,0,i) && ( StoVal0 > m_StoLevel || !m_useStoSignal ))
            ret=-1;
         if(m_useStoSignal)
            if(StoVal1 > StoSig1 && StoVal0 < StoSig0 && StoVal1 >= 100-m_StoLevel)
               ret=-1;
        }

     }
  if(ret != 0)
      Print(__FUNCTION__,": Time=", TimeToString(iTime(NULL,0,i))," ret=",ret);
   return ret;
  }
