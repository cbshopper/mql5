//+------------------------------------------------------------------+
//|                                                     CB_Trend.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#include "CB_IndicatorHelper.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTrend
  {
protected:
   int               maptr1;
   int               maptr2;
   int               period1;
   int               period2;

public:
   int               Init(int p1, int p2)
     {
      maptr1 = iMA(NULL, _Period, period1, 0, MODE_EMA, PRICE_CLOSE);
      maptr2 = iMA(NULL, _Period, period2, 0, MODE_EMA, PRICE_CLOSE);
   
      return 0;
     }

   void              DeInit()
     {
      // delete(matptr1);
      // delete(matptr2);
     }

   int               GetTrend()
     {
      int ret = 0;
      
         int c1 = BarsCalculated(maptr1);
      int c2 = BarsCalculated(maptr2);
      while(c1 < 1 && c2 < 1)
        {
         Sleep(100);
         c1 = BarsCalculated(maptr1);
         c2 = BarsCalculated(maptr2);
        }
      double m1 = GetIndicatorBufferValue(maptr1, 1, 0);
      double m2 = GetIndicatorBufferValue(maptr2, 1, 0);
      if(m1 > m2)
         ret = 1;
      if(m1 < m2)
         ret = -1;
      return ret;
     }


  };


//+------------------------------------------------------------------+
