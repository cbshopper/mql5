//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <cb\CB_IndicatorHelper.mqh>

input string INDICATOR_PARAMETR = "------- Indicator Parameter --------";
input int                 HMAPeriod = 5;         // Period
input int                 HMAShift = 0;           // Shift
input ENUM_APPLIED_PRICE  InpMAPrice = 5;         // Price
input double              Divisor = 2.0;
input int     Filter         = 100;
input bool    Color          = true;
input int     ColorBarBack   = 1;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHullCustom
  {
  
protected:  
 int               data_ptr;

public:
  
   bool              Init()
     {
      data_ptr = iCustom(NULL, PERIOD_CURRENT, "CB/ma/CB_Hull", HMAPeriod, HMAShift, InpMAPrice, Divisor, Filter, Color, ColorBarBack);
      return (data_ptr > 0);
     }
   double            HullValue(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 0);
      return ret;
     }
   double            UpValue(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 1);
      return ret;
     }



                     CHullCustom(void) { };
                    ~CHullCustom(void) {};
  };
//+------------------------------------------------------------------+
