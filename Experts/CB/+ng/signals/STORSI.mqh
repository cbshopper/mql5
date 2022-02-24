//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <cb\CB_IndicatorHelper.mqh>

input string INDICATOR_PARAMETR = "------- Indicator Parameter --------";
input int                     InpStockKPeriod               = 3;                                   // K
input int                     InpStockDPeriod               = 3;                                   // D
input int                     InpRSIPeriod                  = 14;                                  // RSI Period
input int                     InpStochastikPeriod           = 14;                                  // Stochastic Period
input ENUM_APPLIED_PRICE      InpRSIAppliedPrice            = PRICE_CLOSE;                         // RSI Applied Price

#define CUSTOMNAME  "CB\\RSI\\CB_StochRSI"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CStochRSI
  {
  
protected:  
 int               data_ptr;

public:
  
   bool              Init()
     {
      data_ptr = iCustom(NULL, PERIOD_CURRENT, CUSTOMNAME, InpStockKPeriod, InpStockDPeriod, InpRSIPeriod, InpStochastikPeriod, InpRSIAppliedPrice);
      return (data_ptr > 0);
     }
   double            Value(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 0);
      return ret;
     }
   double            Signal(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 1);
      return ret;
     }

   


                     CStochRSI(void) { };
                    ~CStochRSI(void) {};
  };
//+------------------------------------------------------------------+
