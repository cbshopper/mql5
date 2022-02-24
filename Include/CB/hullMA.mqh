//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
/*
https://tradistats.com/hull-moving-average/

Die Berechnung des Hull Moving Average erfolgt in 3 Schritten.

1 Zuerst werden zwei gewichtete gleitende Durchschnitte gebildet.
2 Im zweiten Schritt werden diese beiden Durchschnitte dann in eine Formel eingesetzt.
3 Im letzten Schritt wird aus den Ergebnissen dieser Formel ein neuer gewichteter gleitender Durchschnitt gebildet.

*/
#include <cb\CBUtils5.mqh>
#include <cb\CB_IndicatorHelper.mqh>
#include <cb\CB_MAUtils.mqh>
#include <MovingAverages.mqh>
#include <Indicators\Indicator.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHull: public CIndicator
  {

private :

   int               hull_perid;
   double            hull_divisor;
   ENUM_APPLIED_PRICE m_price;
   int              HmaPeriod  ;
   int               HalfPeriod;
   int                SqrtPeriod ;
   //MqlRates          rates[];
   int               priceCount;
   double             calcfilter(double v0, double v1, int filter)
     {
      double     ret = v0;
      if(filter > 0 &&  v1 > 0)
        {
         if(MathAbs(v0 - v1) < filter * Point())
           {
            ret = v1;
           }
        }
      return ret;
     }


public :
                     CHull()   : hull_perid(1),
                     hull_divisor(1),
                     m_price(PRICE_CLOSE),
                     HmaPeriod(0),
                     HalfPeriod(0),
                     SqrtPeriod(0) {      hull_perid = 0; hull_divisor = 2.0;              }
                    ~CHull()        // ArrayFree(priceArr);
     {
      //  ArrayFree(workHull);
     }

   // double            Values[];
   bool              init(int period, double divisor, ENUM_APPLIED_PRICE price)
     {
      hull_perid = period;
      m_price = price;
      hull_divisor = divisor;
      HmaPeriod  = (int)fmax(hull_perid, 2);
      HalfPeriod = (int)floor(HmaPeriod / hull_divisor);
      SqrtPeriod = (int)floor(sqrt(HmaPeriod));
      //    ArraySetAsSeries(Values, true);
      //    ArrayInitialize(Values, 0);
      //    ArraySetAsSeries(workHull, true);
      //    ArraySetAsSeries(priceArr, true);
      //    ArraySetAsSeries(rates, true);
      //    ArrayResize(workHull, SqrtPeriod + 1);
      priceCount = HmaPeriod * 2 + 1;
      //     ArrayResize(priceArr, priceCount);
      //     ArrayResize(rates, priceCount);
      return true;
     }
   void              deinit()
     {
      //  ArrayFree(priceArr);
      //  ArrayFree(workHull);
     }


   int               calculateTrend(int shift, int filter)
     {
      int ret = 0;
      double vals[];
      int bars = calculate(shift, 4, vals);
      if(bars > 0)
        {
         double v0 = calcfilter(vals[0], vals[1], filter);
         double v1 = calcfilter(vals[1], vals[2], filter);
         if(v0 > v1)
            ret = 1;
         if(v0 < v1)
            ret = -1;
        }
      return ret;
     }
   double            calculateFilter(int shift, int filter)
     {
      double vals[];
      double ret = 0;
      int bars = calculate(shift, 2, vals);
      if(bars > 0)
        {
         ret = calcfilter(vals[0], vals[1], filter);
         /*
         ret = vals[1];
         if(filter > 0 &&  vals[0] > 0)
          {
           if(MathAbs(vals[0] - vals[1]) < filter * Point())
             {
              ret = vals[0];
             }
          }
          */
        }
      return ret;
     }

   double            calculateFilter1(int shift, int filter)
     {
      double v1 = calculate(shift + 1);
      double v0 = calculate(shift);
      double ret = calcfilter(v0, v1, filter);
      /*
      if(filter > 0 &&  v1 > 0)
       {
        if(MathAbs(ret - v1) < filter * Point())
          {
           ret = v1;
          }
       }
       */
      return ret;
     }

   double            calculate(int shift)
     {
      double priceArr[];
      ArraySetAsSeries(priceArr, true);
      ArrayResize(priceArr, priceCount);
      MqlRates          rates[];
      ArraySetAsSeries(rates, true);
      ArrayResize(rates, priceCount);
      double ret = 0;
      if(shift < 0)
         return 0;
      long copied = CopyRates(Symbol(), 0, shift, priceCount, rates);
      if(copied >= priceCount)
        {
         for(int i = 0; i < priceCount; i++)
           {
            priceArr[i] = _getPrice(m_price, rates[i]);
           }
         ret = getHull(0, priceArr);
         //       if(ArraySize(Values) < shift + 1)
         //          ArrayResize(Values, shift + 1);
         //       Values[shift] = ret;
        }
      return ret;
     }

   int               calculate(int shift, int bars, double &values[])
     {
      double priceArr[];
      ArraySetAsSeries(priceArr, true);
      ArrayResize(priceArr, priceCount + bars+1);
      MqlRates          rates[];
      ArraySetAsSeries(rates, true);
      ArrayResize(rates, priceCount + bars+1);
      if(shift < 0)
         return 0;
      long copied = CopyRates(Symbol(), 0, shift, priceCount + bars, rates);
      if(copied >= priceCount)
        {
         ArrayResize(values, bars);
         for(int bar = 0; bar < copied; bar ++)
           {
            priceArr[bar] = _getPrice(m_price, rates[bar]);
           }
         for(int bar = 0; bar < copied-priceCount; bar ++)
           {
            double ret = getHull(bar, priceArr);
            values[bar] = ret;
           }
        }
      else
         bars = 0;
      return bars;
     }



   double            getHull(int shift, double &priceArr[])
     {
      double            workHull[];
      ArrayResize(workHull, SqrtPeriod + 1);
      ArraySetAsSeries(workHull, true);
      for(int i = SqrtPeriod ; i >= 0; i--)
        {
         // // HMA= WMA(2*WMA(n/2) - WMA(n))
         //1. Calculate a Weighted Moving Average with period n / 2 and multiply it by 2
         double halfma = iMAOnArray(priceArr, 0, HalfPeriod, 0, MODE_LWMA, shift + i);
         //2. Calculate a Weighted Moving Average for period n and subtract if from step 1
         double fullma = iMAOnArray(priceArr, 0, HmaPeriod, 0, MODE_LWMA, shift + i);
         workHull[i] = 2.0 * halfma - fullma;
        }
      //3. Calculate a Weighted Moving Average with period sqrt(n) using the data from step 2
      double hullma = iMAOnArray(workHull, 0, SqrtPeriod, 0, MODE_LWMA, 0);
      return(hullma);
     }


  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHullEA
  {

private :
   int               ima1;
   int               ima2;

   int HalfPeriod ;
   int SqrtPeriod ;
   double            lastVal;
   double            warr[];
   ENUM_APPLIED_PRICE m_price;
   ENUM_TIMEFRAMES   hull_perid;


public:
                     CHullEA()   : hull_perid(1),
                     m_price(PRICE_CLOSE)
     {      hull_perid = 0;              }

                    ~CHullEA()       { ArrayFree(warr);  }


   bool              init(int period, double divisor, ENUM_APPLIED_PRICE price)
     {
      hull_perid = (ENUM_TIMEFRAMES)period;
      m_price = price;
      HalfPeriod = (int)MathFloor(period / divisor);
      SqrtPeriod = (int)MathFloor(MathSqrt(period));
      ENUM_MA_METHOD method = MODE_LWMA;
      ima1 = iMA(NULL, PERIOD_CURRENT, HalfPeriod, 0, method, m_price);
      ima2 = iMA(NULL, PERIOD_CURRENT, period,     0, method, m_price);
      ArraySetAsSeries(warr, true);
      ArrayResize(warr, SqrtPeriod  + 1);
      return true;
     }


   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   double CHullEA::  calculate(int shift)
     {
      //--- hull moving average 1st buffer
      if(BarsCalculated(ima1) < Bars(NULL, 0))
         return 0;
      for(int i = SqrtPeriod ; i >= 0; i--)
        {
         //  ENUM_APPLIED_PRICE price = maprice;
         //  if ((i+shift) == 0) price = PRICE_OPEN;
         //double halfma = iMA(NULL, TimeFrame, HalfPeriod, 0, MODE_LWMA, maprice, i + shift);
         //double fullma = iMA(NULL, TimeFrame, period,     0, MODE_LWMA, maprice, i + shift);
         double halfma = GetIndicatorValue(ima1, i + shift);
         double fullma = GetIndicatorValue(ima2, i + shift);
         //  warr[i] = 2.0 * iMA(NULL, TimeFrame, HalfPeriod, 0, MODE_LWMA, maprice, i + shift) - iMA(NULL, TimeFrame, period, 0, MODE_LWMA, maprice, i + shift);
         warr[i] = 2.0 *  halfma - fullma;
        }
      double ret = iMAOnArray(warr, 0, SqrtPeriod, 0, MODE_LWMA, 0);
      //   double ret =  LinearWeightedMAOnBuffer(0,SqrtPeriod,warr);
      return ret;
     }
   //+------------------------------------------------------------------+
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   double            CHullEA::calculateFilter(int shift, int filter)
     {
      double ret = calculate(shift);
      if(filter > 0 && lastVal > 0)
        {
         if(MathAbs(ret - lastVal) < filter * Point())
           {
            ret = lastVal;
           }
        }
      lastVal  = ret;
      return ret;
     }
   //+------------------------------------------------------------------+
  };
//+------------------------------------------------------------------+
