//+------------------------------------------------------------------+
//|                                                       CBHull.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <Indicators\Indicator.mqh>
//+------------------------------------------------------------------+
//| Class CHull.                                                      |
//| Purpose: Class of the "Moving Average" indicator.                |
//|          Derives from class CIndicator.                          |
//+------------------------------------------------------------------+
class CiHull : public CIndicator
  {
protected:
   int               m_ma_period;
   int               m_ma_shift;
   int               m_applied;
   double            m_divisor;
   int               m_filter;
   string            m_customname;

public:
                     CiHull(void);
                    ~CiHull(void);
/*
input int                 HMAPeriod=12;           // Period
input int                 HMAShift=0;             // Shift
input ENUM_APPLIED_PRICE  InpMAPrice=5;           // Price
input double              Divisor = 2.0;
input int     Filter         = 0;
*/                    
                    
                    
   //--- methods of access to protected data
   int               MaPeriod(void)        const { return(m_ma_period); }
   int               MaShift(void)         const { return(m_ma_shift);  }
   int               Applied(void)         const { return(m_applied);   }
   int               Filter(void)         const { return(m_filter);   }
   //--- method of creation
   bool              Create(const string symbol,const ENUM_TIMEFRAMES period,
                            const int ma_period,const int ma_shift,
                            const int applied, const int filter);
   //--- methods of access to indicator data
   double            Main(const int index) const;
   //--- method of identifying
   virtual int       Type(void) const { return(IND_MA); }

protected:
   //--- methods of tuning
   virtual bool      Initialize(const string symbol,const ENUM_TIMEFRAMES period,const int num_params,const MqlParam &params[]);
   bool              Initialize(const string symbol,const ENUM_TIMEFRAMES period,
                                const int ma_period,const int ma_shift,
                                const int appliend, const double divisor, const int filter);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CiHull::CiHull(void) : m_ma_period(-1),
                   m_ma_shift(-1),
                   m_applied(-1),
                   m_divisor(2.0),
                   m_filter(0)
  {
    m_customname="CB\ma\CB_Hull";
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CiHull::~CiHull(void)
  {
  }
//+------------------------------------------------------------------+
//| Create indicator "Moving Average"                                |
//+------------------------------------------------------------------+
bool CiHull::Create(const string symbol,const ENUM_TIMEFRAMES period,
                  const int ma_period,const int ma_shift,
                  const int applied, const int m_filter)
  {
//--- check history
   if(!SetSymbolPeriod(symbol,period))
      return(false);
//--- create
  //  m_handle=iMA(symbol,period,ma_period,ma_shift,ma_method,applied);
  m_handle=iCustom(symbol,period,m_customname,   ma_period,ma_shift,applied,2.0,m_filter);
//--- check result
   if(m_handle==INVALID_HANDLE)
      return(false);
//--- indicator successfully created
   if(!Initialize(symbol,period,ma_period,ma_shift,applied,2.0,m_filter))
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
bool CiHull::Initialize(const string symbol,const ENUM_TIMEFRAMES period,const int num_params,const MqlParam &params[])
  {
   return(Initialize(symbol,period,
          (int)params[0].integer_value,
          (int)params[1].integer_value,
          (int)params[2].integer_value,
          (double)params[3].double_value,
          (int)params[4].integer_value)
      );
  }
//+------------------------------------------------------------------+
//| Initialize indicator with the special parameters                 |
//+------------------------------------------------------------------+
bool CiHull::Initialize(const string symbol, const ENUM_TIMEFRAMES period,
                     const int ma_period,
                     const int ma_shift,
                     const int applied, 
                     const double divisor, 
                     const int filter)
  {
   if(CreateBuffers(symbol,period,1))
     {
      //--- string of status of drawing
      m_name  ="MA";
      m_status="("+symbol+","+PeriodDescription()+","+
               IntegerToString(ma_period)+","+IntegerToString(ma_shift)+","+
               PriceDescription(applied)+ ",D=" + IntegerToString(divisor) + "F="+ IntegerToString(divisor)+","+ 
               "H="+IntegerToString(m_handle) + ")";
      //--- save settings
      m_ma_period=ma_period;
      m_ma_shift =ma_shift;
      m_applied  =applied;
      m_divisor=divisor;
      m_filter=filter;
      //--- create buffers
      ((CIndicatorBuffer*)At(0)).Name("MAIN_LINE");
      ((CIndicatorBuffer*)At(0)).Offset(ma_shift);
      //--- ok
      return(true);
     }
//--- error
   return(false);
  }
//+------------------------------------------------------------------+
//| Access to buffer of "Moving Average"                             |
//+------------------------------------------------------------------+
double CiHull::Main(const int index) const
  {
   CIndicatorBuffer *buffer=At(0);
//--- check
   if(buffer==NULL)
      return(EMPTY_VALUE);
//---
   return(buffer.At(index));
  }