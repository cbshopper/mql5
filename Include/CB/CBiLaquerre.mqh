//+------------------------------------------------------------------+
//|                                                     Laquerre.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
// C:\ProgrammeXL\Office\MetaTrader5.dev\MQL5\Include\CB\CBiLaquerre.mqh
#include <Indicators\Indicator.mqh>
//+------------------------------------------------------------------+
//| Class CiLaquerre.                                                      |
//| Purpose: Class of the "Laquerre" indicator.                |
//|          Derives from class CIndicator.                          |
//+------------------------------------------------------------------+
class CiLaquerre : public CIndicator
  {
protected:
   double               m_gamma;
   string            m_customname;

public:
                     CiLaquerre(void);
                    ~CiLaquerre(void);
                   
                    
                    
   //--- methods of access to protected data
   int               Gamma(void)        const { return(m_gamma); }
   //--- method of creation
   bool              Create(const string symbol,const ENUM_TIMEFRAMES period,
                            const double gamma);
   //--- methods of access to indicator data
   double            Main(const int index) const;
   //--- method of identifying
   virtual int       Type(void) const { return(IND_MA); }

protected:
   //--- methods of tuning
   virtual bool      Initialize(const string symbol,const ENUM_TIMEFRAMES period,const int num_params,const MqlParam &params[]);
   bool              Initialize(const string symbol,const ENUM_TIMEFRAMES period,
                                const double gamma);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CiLaquerre::CiLaquerre(void) : m_gamma(0.7)
  {
    m_customname="Laguerre\\laguerre";
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CiLaquerre::~CiLaquerre(void)
  {
  }
//+------------------------------------------------------------------+
//| Create indicator "Moving Average"                                |
//+------------------------------------------------------------------+
bool CiLaquerre::Create(const string symbol,const ENUM_TIMEFRAMES period,
                  double gamma)
  {
//--- check history
   if(!SetSymbolPeriod(symbol,period))
      return(false);
//--- create
  //  m_handle=iMA(symbol,period,ma_period,ma_shift,ma_method,applied);
  m_handle=iCustom(symbol,period,m_customname,   gamma);
//--- check result
   if(m_handle==INVALID_HANDLE)
      return(false);
//--- indicator successfully created
   if(!Initialize(symbol,period,gamma))
     {
      //--- initialization failed
      IndicatorRelease(m_handle);
      m_handle=INVALID_HANDLE;
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize the indicator with universal parameters               |
//+------------------------------------------------------------------+
bool CiLaquerre::Initialize(const string symbol,const ENUM_TIMEFRAMES period,const int num_params,const MqlParam &params[])
  {
   return(Initialize(symbol,period,
          (int)params[0].double_value)
      );
  }
//+------------------------------------------------------------------+
//| Initialize indicator with the special parameters                 |
//+------------------------------------------------------------------+
bool CiLaquerre::Initialize(const string symbol, const ENUM_TIMEFRAMES period,
                      double gamma)
  {
   if(CreateBuffers(symbol,period,1))
     {
      //--- string of status of drawing
      m_name  ="Laquerre";
      m_status="("+symbol+","+PeriodDescription()+", ("+ DoubleToString(gamma) + "))";
      //--- save settings
      m_gamma=gamma;
      //--- create buffers
      ((CIndicatorBuffer*)At(0)).Name("MAIN_LINE");
      //--- ok
      return(true);
     }
//--- error
   return(false);
  }
//+------------------------------------------------------------------+
//| Access to buffer of "Moving Average"                             |
//+------------------------------------------------------------------+
double CiLaquerre::Main(const int index) const
  {
   CIndicatorBuffer *buffer=At(0);
//--- check
   if(buffer==NULL)
      return(EMPTY_VALUE);
//---
   return(buffer.At(index));
  }