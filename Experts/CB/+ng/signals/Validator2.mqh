//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <cb\CB_IndicatorHelper.mqh>

input string INDICATOR_PARAMETR = "------- Indicator Parameter --------";
input int                 ma1_period = 5;        
input int                 ma2_period = 15;
input ENUM_MA_METHOD      ma1_mode = MODE_EMA;
input ENUM_MA_METHOD      ma2_mode = MODE_EMA;    
input ENUM_APPLIED_PRICE  ma1_price = PRICE_OPEN;
input ENUM_APPLIED_PRICE  ma2_price = PRICE_OPEN;
input int                 ma1_shift = 0;
input int                 ma2_shift = 0;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CValidator2
  {

protected:
   int               data_ptr;

public:

   bool              Init()
     {
      data_ptr = iCustom(NULL, PERIOD_CURRENT, "CB/ma/CB_TestValidator", ma1_period, ma2_period, ma1_mode, ma2_mode, ma1_price, ma2_price,ma1_shift,ma2_shift,90,1);
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

   double            MA1Value(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 4);
      return ret;
     }
   double            MA2Value(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 5);
      return ret;
     }



                     CValidator2(void) { };
                    ~CValidator2(void) {};
  };
//+------------------------------------------------------------------+
