//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <cb\CB_IndicatorHelper.mqh>

input string INDICATOR_PARAMETR = "------- Indicator Parameter --------";
input int                 PBRange = 20;
input double              LevelInvert = 5.0;
input double              LevelFollow = 2.5;
input int                 OrderBarCount = 4;

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
      data_ptr = iCustom(NULL, PERIOD_CURRENT, "CB/Validators/CB_PBValidator", PBRange, LevelInvert, LevelFollow, OrderBarCount, /* canstants for drawing orderlines */ 30,1,0,0,1);
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

   double            Value(int shift)
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
