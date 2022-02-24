//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <cb\CB_IndicatorHelper.mqh>

input string INDICATOR_PARAMETR = "------- Indicator Parameter --------";
input int InpDepth    =12;  // Depth
input int InpDeviation=5;   // Deviation
input int InpBackstep =3;   // Back Step


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCustomIndicator
  {
  
protected:  
 int               data_ptr;

public:
  
   bool              Init()
     {
      data_ptr = iCustom(NULL, PERIOD_CURRENT, "Examples//ZigZag", InpDepth, InpDeviation, InpBackstep);
      return (data_ptr > 0);
     }
   double            Ma(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 0);
      return ret;
     }
     /*
   double            UpperBand(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 1);
      return ret;
     }

   double            LowerBand(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 2);
      return ret;
     }
   double            TriggerSlow(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 3);
      return ret;
     }
   double            TriggerFast(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 4);
      return ret;
     }
   double            BuySignal(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 5);
      return ret;
     }
   double            SellSignal(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 6);
      return ret;
     }
     */


                     CCustomIndicator(void) { };
                    ~CCustomIndicator(void) {};
  };
//+------------------------------------------------------------------+
