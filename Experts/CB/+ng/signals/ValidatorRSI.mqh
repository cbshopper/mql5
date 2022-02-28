//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <cb\CB_IndicatorHelper.mqh>

input string INDICATOR_PARAMETR = "------- Indicator Parameter --------";
input int                 rsi_period = 14;
input ENUM_APPLIED_PRICE  rsi_price = PRICE_CLOSE;
input int                 rsi_level = 30;
input int                 rsi_buylevel = 10;
input int                 rsi_selllevel = 90;

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
      data_ptr = iCustom(NULL, PERIOD_CURRENT, "CB/Validators/CB_RSIValidator", rsi_period, rsi_price, rsi_level, rsi_buylevel, rsi_selllevel, 30,1,0,0,1);
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

   double            RSIValue(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 4);
      return ret;
     }
     /*
   double            MA2Value(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 5);
      return ret;
     }

*/

                     CValidator(void) { };
                    ~CValidator(void) {};
  };
//+------------------------------------------------------------------+
