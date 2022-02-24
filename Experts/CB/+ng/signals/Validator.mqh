//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <cb\CB_IndicatorHelper.mqh>

input string INDICATOR_PARAMETR = "------- Indicator Parameter --------";
input int                 HMAPeriod = 5;         // Period
//input int                 HMAShift = 0;           // Shift
input ENUM_APPLIED_PRICE  HMAPrice = PRICE_MEDIAN;         // Price
input double              Divisor = 2.0;
input int     Filter         = 50;
input bool    Color          = true;
input int     ColorBarBack   = 1;
input int ValidateTimeDays = 30;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CValidator
  {

protected:
   int               data_ptr;

public:

   bool              Init()
     {
      data_ptr = iCustom(NULL, PERIOD_CURRENT, "CB/ma/CB_HullSignalValidator", HMAPeriod,/* HMAShift,*/ HMAPrice, Divisor, Filter, Color, ColorBarBack, ValidateTimeDays,1);
      Print(__FUNCTION__, ": data_ptr=", data_ptr);
   //   return (data_ptr > 0);
      if(data_ptr > 0)
        {
         int calculated = BarsCalculated(data_ptr);
         int retrycount = 0;
         while(calculated < 100 && retrycount < 5)
           {
            Sleep(1000);
            calculated = BarsCalculated(data_ptr);
            retrycount++;
           }
         Print(__FUNCTION__, " calculated=", calculated);
         if(calculated < 100)
            return false;
         return true;
        }
      return false;
     }
   double            OpenBuy(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 0);
      return ret;
     }
   double            OpenSell(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 1);
      return ret;
     }
   double            CloseBuy(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 2);
      return ret;
     }
   double            CloseSell(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 3);
      return ret;
     }

   double            HullValue(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 4);
      return ret;
     }
   double            UpValue(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 5);
      return ret;
     }



                     CValidator(void) { };
                    ~CValidator(void) {};
  };
//+------------------------------------------------------------------+
