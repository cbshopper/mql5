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
#include <cb\CB_MAUtils.mqh>
#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHull
  {

private :

   double            priceArr[];
   double            workHull[];
   int               m_period;
   double            m_divisor;
   ENUM_APPLIED_PRICE m_price;
   int              HmaPeriod  ;
   int               HalfPeriod;
   int                SqrtPeriod ;
   MqlRates          rates[];
   int               cnt;
   double            lastVal;


public :
                     CHull()   : m_period(1),
                     m_divisor(1),
                     m_price(PRICE_CLOSE),
                     HmaPeriod(0),
                     HalfPeriod(0),
                     SqrtPeriod(0) {      m_period = 0; m_divisor = 2.0;              }
                    ~CHull()       { ArrayFree(priceArr); ArrayFree(workHull); }

   bool              init(int period, double divisor, ENUM_APPLIED_PRICE price)
     {
      m_period = period;
      m_price = price;
      lastVal=0;
      HmaPeriod  = (int)fmax(m_period, 2);
      HalfPeriod = (int)floor(HmaPeriod / m_divisor);
      SqrtPeriod = (int)floor(sqrt(HmaPeriod));

      ArraySetAsSeries(workHull, true);
      ArraySetAsSeries(priceArr, true);
      ArraySetAsSeries(rates,true);
      ArrayResize(workHull, SqrtPeriod+1);
      cnt = HmaPeriod*2+1;
      ArrayResize(priceArr,cnt);
      ArrayResize(rates,cnt);
      return true;
     }

   double            calculateFilter(long shift, int filter)
     {
      double ret=calculate(shift);
      if(filter > 0 && lastVal > 0)
        {
         if(MathAbs(ret - lastVal) < filter * Point())
           {
            ret = lastVal;
           }
        }
      lastVal  =ret;
      return ret;
     }

   double            calculate(long shift)
     {
      double ret = 0;
      //   ArraySetAsSeries(rates,false);
      if (shift <0) return 0;
      long copied=CopyRates(Symbol(),0,shift,cnt,rates);
      if(copied >= cnt)
        {
         for(int i=0; i<cnt; i++)
           {
            priceArr[i] = _getPrice(m_price, rates[i]);
           }
         ret = getHull(0);
        }
      return ret;
     }

   double            getHull(int shift)
     {

      double hma, hmw, weight;
      for(int i = SqrtPeriod ; i >= 0; i--)
        {
         // // HMA= WMA(2*WMA(n/2) - WMA(n))

         //1. Calculate a Weighted Moving Average with period n / 2 and multiply it by 2
         // double halfma = LinearWeightedMA(0,HalfPeriod,priceArr);
         double halfma = iMAOnArray(priceArr, 0, HalfPeriod, 0, MODE_LWMA, shift+ i);

         //2. Calculate a Weighted Moving Average for period n and subtract if from step 1
         //double fullma =  LinearWeightedMA(0,HmaPeriod,priceArr);
         double fullma = iMAOnArray(priceArr, 0, HmaPeriod, 0, MODE_LWMA, shift+ i);
         //workHull[arrIndex] -= fullma;  //  2*WMA(n/2) - WMA(n)
         workHull[i] = 2.0 * halfma - fullma;
        }

      //3. Calculate a Weighted Moving Average with period sqrt(n) using the data from step 2
      // double hullma =  LinearWeightedMA(0,SqrtPeriod,workHull);
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
   ENUM_TIMEFRAMES   m_period;


public:
                     CHullEA()   : m_period(1),
                     m_price(PRICE_CLOSE)
     {      m_period = 0;              }
                    ~CHullEA()       { ArrayFree(warr);  }
   bool              init(int period, double divisor, ENUM_APPLIED_PRICE price)
     {
      m_period = period;
      m_price = price;
      HalfPeriod = MathFloor(period / divisor);
      SqrtPeriod = MathFloor(MathSqrt(period));
      ENUM_MA_METHOD method=MODE_LWMA;
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

      if(BarsCalculated(ima1) < Bars(NULL,0))
         return 0;

      for(int i = SqrtPeriod ; i >= 0; i--)
        {
         //  ENUM_APPLIED_PRICE price = maprice;
         //  if ((i+shift) == 0) price = PRICE_OPEN;

         //double halfma = iMA(NULL, TimeFrame, HalfPeriod, 0, MODE_LWMA, maprice, i + shift);
         //double fullma = iMA(NULL, TimeFrame, period,     0, MODE_LWMA, maprice, i + shift);
         double halfma = GetIndicatorValue(ima1,i+shift);
         double fullma = GetIndicatorValue(ima2,i+shift);
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
   double            CHullEA::calculateFilter(int shift,int filter)
     {
      double ret=calculate(shift);
      if(filter > 0 && lastVal > 0)
        {
         if(MathAbs(ret - lastVal) < filter * Point())
           {
            ret = lastVal;
           }
        }
      lastVal  =ret;
      return ret;
     }
   //+------------------------------------------------------------------+
  };
//+------------------------------------------------------------------+
