//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <cb\CB_IndicatorHelper.mqh>

input string INDICATOR_PARAMETR = "------- Indicator Parameter --------";
input int    MAPeriod = 40; // MA Period for Hull & Band
input int    TriggerPeriod = 10; // Trigger-Period
input int    TriggerPeriodDelta = 2; // Trigger-Period Delta
input double Divisor = 2.0;
input double Deviation = 1.0;
input int    MinDiff = 1;
input int    TrendPeriod=20;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHullBollinger
  {
  
protected:  
 int               data_ptr;

public:
  
   bool              Init()
     {
      data_ptr = iCustom(NULL, PERIOD_CURRENT, "CB/ma/CB_HullBollinger", MAPeriod, TriggerPeriod, TriggerPeriodDelta, Divisor, Deviation, MinDiff,TrendPeriod);
      return (data_ptr > 0);
     }
   double            Ma(int shift)
     {
      double ret = GetIndicatorBufferValue(data_ptr, shift, 0);
      return ret;
     }
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


                     CHullBollinger(void) { };
                    ~CHullBollinger(void) {};
  };
//+------------------------------------------------------------------+
