//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//|                                                 SignalHullMA.mqh |
//|                   Copyright 2009+2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#include <Expert\ExpertSignal.mqh>
#include <CB\CBiLaquerre.mqh>

#define SELL_FORBIDDEN 9999
#define BUY_FORBIDDEN -9999


// wizard description start
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//| Description of the class                                         |
//| Title=Signals of indicator 'Laquerre'  FILTER!                   |
//| Type=SignalAdvanced                                              |
//| Name=Laquerre Filter                                             |
//| ShortName=Laquerre                                               |
//| Class=CSignalLaquerreFilter                                            |
//| Page=signal_ma                                                   |
//| Parameter=Gamma,double,0.7,Gamma Value                           |
//| Parameter=LoLevel,double,0.15,Lo Signal Level                    |
//| Parameter=HiLevel,double,0.75,Hi Signal Level                    |
//+------------------------------------------------------------------+
// wizard description end
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//| Class CSignalLaquerreFilter.                                             |
//| Purpose: Class of generator of trade signals based on            |
//|          the 'Laquerre' indicator.                    |
//| Is derived from the CExpertSignal class.                         |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
class CSignalLaquerreFilter : public CExpertSignal
  {
protected:
   CiLaquerre              m_laq;             // object+indicator
   //+++ adjusted parameters
   double               m_gamma;      // the "gamma" parameter of the indicator
   double               m_lolevel;      // the level sell for signals
   double               m_hilevel;      // the level buy for signals
   //+++ "weights" of market models (0+100)
   int               m_pattern_0;      // model 0 "MA turns"
   int               m_pattern_1;      // model 0 "MA turns"

public:
                     CSignalLaquerreFilter(void);
                    ~CSignalLaquerreFilter(void);
   //+++ methods of setting adjustable parameters
   void              Gamma(double value)                 { m_gamma=value;          }
   void              LoLevel(double value)                 { m_lolevel=value;          }
   void              HiLevel(double value)                 { m_hilevel=value;          }

   //+++ methods of adjusting "weights" of market models
   void              Pattern_0(int value)                { m_pattern_0=value;          }
   void              Pattern_1(int value)                { m_pattern_1=value;          }
   //+++ method of verification of settings
   virtual bool      ValidationSettings(void);
   //+++ method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators *indicators);
   //+++ methods of checking if the market models are formed
   virtual double    Direction(void);

protected:
   //+++ method of initialization of the indicator
   bool              InitMA(CIndicators *indicators);
   //+++ methods of getting data
   double            LAQ(int ind)                         { return(m_laq.Main(ind));     }

  };
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//| Constructor                                                      |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CSignalLaquerreFilter::CSignalLaquerreFilter(void) :
   m_gamma(0.7),
   m_lolevel(0.15),
   m_hilevel(0.75),
   m_pattern_0(40),
   m_pattern_1(80)
  {
//+++ initialization of protected data
   m_used_series=USE_SERIES_OPEN+USE_SERIES_HIGH+USE_SERIES_LOW+USE_SERIES_CLOSE;
  }
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//| Destructor                                                       |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
CSignalLaquerreFilter::~CSignalLaquerreFilter(void)
  {
//m_ma.deinit();
  }
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//| Validation settings protected data.                              |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
bool CSignalLaquerreFilter::ValidationSettings(void)
  {
//+++ validation settings of additional filters
   if(!CExpertSignal::ValidationSettings())
      return(false);
//+++ initial data checks
   if(m_gamma<=0)
     {
      printf(__FUNCTION__+": gamma must be greater than 0");
      return(false);
     }
//+++ ok
   return(true);
  }
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//| Create indicators.                                               |
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
bool CSignalLaquerreFilter::InitIndicators(CIndicators *indicators)
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
bool CSignalLaquerreFilter::InitMA(CIndicators *indicators)
  {
//+++ check pointer
   if(indicators==NULL)
      return(false);
//+++ add object to collection
   if(!indicators.Add(GetPointer(m_laq)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- initialize object
   if(!m_laq.Create(m_symbol.Name(),m_period,m_gamma))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//+++ ok
   return(true);
  }
  
//+------------------------------------------------------------------+
//| Check conditions for laquerre filter.                            |
//+------------------------------------------------------------------+
double CSignalLaquerreFilter::Direction(void)
  {
   int idx   =StartIndex();
//---
   double val0 = LAQ(idx);
   double val1 = LAQ(idx+1);
   if(val0 > m_hilevel || val1<val0 )     // value is at upper level
     {
        return SELL_FORBIDDEN;
     }
   if(val0 < m_lolevel || val1<val0)    // value raises to upper level
     {
       return BUY_FORBIDDEN;
     }
   
//--- condition OK
   return(0.0);
  }
 