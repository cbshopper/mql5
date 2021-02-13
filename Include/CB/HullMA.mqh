//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
double _getPrice(int priceType, int index)
  {
   double price = 0.0;
   switch(priceType)
     {
      case PRICE_OPEN    :
         price = Open[index];
         break;

      case PRICE_HIGH    :
         price = High[index];
         break;

      case PRICE_LOW     :
         price = Low[index];
         break;

      case PRICE_MEDIAN  :
         price = (High[index] + Low[index]) / 2.0;
         break;

      case PRICE_TYPICAL :
         price = (High[index] + Low[index] + Close[index]) / 3.0;
         break;


      case PRICE_WEIGHTED:
         price = (High[index] + Low[index] + 2 * Close[index]) / 4.0;
         break;



      case PRICE_CLOSE   :
      default            :
         price = Close[index];
         break;


     }



   return(price);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHull
  {

private :

   double            workHull1[];
   double            workHull2[];
   int               m_period;
   double            m_divisor;
   ENUM_APPLIED_PRICE m_price;
   int HmaPeriod  ;
   int               HalfPeriod;
   int HullPeriod ;


public :
                     CHull()   : m_period(1), m_divisor(1), m_price(0), HmaPeriod(0), HalfPeriod(0), HullPeriod(0) {    ArrayResize(workHull1, Bars); ArrayResize(workHull2, Bars);   m_period = 0; m_divisor = 1.0;              }
                    ~CHull()     { ArrayFree(workHull1); ArrayFree(workHull2); }

   bool              init(int period, double divisor, ENUM_APPLIED_PRICE price)
     {
      m_period = period;
      m_divisor = divisor;
      m_price = price;
      HmaPeriod  = (int)fmax(m_period, 2);
      HalfPeriod = (int)floor(HmaPeriod / m_divisor);
      HullPeriod = (int)floor(sqrt(HmaPeriod));

      return true;
     }

   double            calculate(int i, int bars, ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT)
     {
      double value = _getPrice(m_price, i);
      //double value = iMA(NULL,TimeFrame,1,0,MODE_SMA,m_price,i);


      // double ret = calculate(value,bars-i-1,bars);
      double ret = calculate(value, i, bars);
      return ret;
     }

   double            calculate(double price, int i, int bars)
     {
      int k;
      if(ArrayRange(workHull1, 0) != bars)
         ArrayResize(workHull1, bars);
      if(ArrayRange(workHull2, 0) != bars)
         ArrayResize(workHull2, bars);

      int r = bars - i - 1;
      workHull1[r] = price;
      if(m_period <= 1)
         return(price);


      double hma, hmw, weight;
      hmw = HalfPeriod;
      hma = hmw * price;
      for(k = 1; k < HalfPeriod && (r - k) >= 0; k++)
        {
         weight = HalfPeriod - k;
         hmw   += weight;
         hma   += weight * workHull1[r - k];
        }

      workHull2[r] = 2.0 * hma / hmw;
      hmw = HmaPeriod;
      hma = hmw * price;
      for(k = 1; k < m_period && (r - k) >= 0; k++)
        {
         weight = HmaPeriod - k;
         hmw   += weight;
         hma   += weight * workHull2[r - k];
        }

      workHull2[r] -= hma / hmw;
      hmw = HullPeriod;
      hma = hmw * workHull2[r];
      for(k = 1; k < HullPeriod && (r - k) >= 0; k++)
        {
         weight = HullPeriod - k;
         hmw   += weight;
         hma   += weight * workHull2[r - k];
        }
      return(hma / hmw);
     }


  };



// from 4-time-frame-hull-trend
double workHull[][10];
double iHull(double price, double period, int r, int instanceNo = 0)
  {
   int k;
   if(ArrayRange(workHull, 0) != Bars)
      ArrayResize(workHull, Bars);
   r = Bars - r - 1;

   int HmaPeriod  = MathMax(period, 2);
   int HalfPeriod = MathFloor(HmaPeriod / 2);
   int HullPeriod = MathFloor(MathSqrt(HmaPeriod));
   double hma, hmw, weight;
   instanceNo *= 2;

   workHull[r][instanceNo] = price;

// https://www.fidelity.com/learning-center/trading-investing/technical-analysis/technical-indicator-guide/hull-moving-average
// HMA= WMA(2*WMA(n/2) - WMA(n)),sqrt(n))

//1. Calculate a Weighted Moving Average with period n / 2 and multiply it by 2
   hmw = HalfPeriod;
   hma = hmw * price;
   for(k = 1; k < HalfPeriod && (r - k) >= 0; k++)
     {
      weight = HalfPeriod - k;
      hmw   += weight;
      hma   += weight * workHull[r - k][instanceNo];
     }
   workHull[r][instanceNo + 1] = 2.0 * hma / hmw;

//2. Calculate a Weighted Moving Average for period n and subtract if from step 1
   hmw = HmaPeriod;
   hma = hmw * price;
   for(k = 1; k < period && (r - k) >= 0; k++)
     {
      weight = HmaPeriod - k;
      hmw   += weight;
      hma   += weight * workHull[r - k][instanceNo];
     }
   workHull[r][instanceNo + 1] -= hma / hmw;

//3. Calculate a Weighted Moving Average with period sqrt(n) using the data from step 2
   hmw = HullPeriod;
   hma = hmw * workHull[r][instanceNo + 1];
   for(k = 1; k < HullPeriod && (r - k) >= 0; k++)
     {
      weight = HullPeriod - k;
      hmw   += weight;
      hma   += weight * workHull[r - k][1 + instanceNo];
     }
   return(hma / hmw);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iHullEA(string symbol, int TimeFrame, int maprice, int period, double divisor, int shift)
  {
   int HalfPeriod = MathFloor(period / divisor);
   int SqrtPeriod = MathFloor(MathSqrt(period));
   int factor=1;
//--- hull moving average 1st buffer

   double warr[];
   ArraySetAsSeries(warr, true);
   ArrayResize(warr, SqrtPeriod * factor + 1);


   for(int i = SqrtPeriod * factor; i >= 0; i--)
     {
      //  ENUM_APPLIED_PRICE price = maprice;
      //  if ((i+shift) == 0) price = PRICE_OPEN;

      double halfma = iMA(NULL, TimeFrame, HalfPeriod, 0, MODE_LWMA, maprice, i + shift);
      double fullma = iMA(NULL, TimeFrame, period,     0, MODE_LWMA, maprice, i + shift);

      //  warr[i] = 2.0 * iMA(NULL, TimeFrame, HalfPeriod, 0, MODE_LWMA, maprice, i + shift) - iMA(NULL, TimeFrame, period, 0, MODE_LWMA, maprice, i + shift);
      warr[i] = 2.0 *  halfma - fullma;
     }
   double ret = iMAOnArray(warr, 0, SqrtPeriod, 0, MODE_LWMA, 0);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iHullEAF(string symbol, int TimeFrame, int maprice, int period, double divisor,int filter, double &lastVal, int shift)
  {
   double ret=iHullEA(symbol,TimeFrame,maprice,period,divisor,shift);
   if(filter > 0 && lastVal > 0)
     {
      if(MathAbs(ret - lastVal) < filter * Point)
        {
         ret = lastVal;
        }
     }
   lastVal  =ret;
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iHullEAxx(string symbol, int TimeFrame, int maprice, int period, double divisor,int filter, int shift)
  {
   double ret=0;
   int HalfPeriod = MathFloor(period / divisor);
   int SqrtPeriod = MathFloor(MathSqrt(period));
   int factor=1.2;
//--- hull moving average 1st buffer

   double warr[];
   ArraySetAsSeries(warr, true);
   int arrLen = SqrtPeriod * factor + 1;
   ArrayResize(warr,arrLen);

   ArrayFill(warr,0,arrLen,0);
   for(int i = SqrtPeriod * factor; i >= 0; i--)
     {
      double halfma = iMA(NULL, TimeFrame, HalfPeriod, 0, MODE_LWMA, maprice, i + shift);
      double fullma = iMA(NULL, TimeFrame, period, 0, MODE_LWMA, maprice, i + shift);
      warr[i] = 2.0 *  halfma - fullma;
     }
   double ma0 = iMAOnArray(warr, 0, SqrtPeriod, 0, MODE_LWMA, 0);

   /*
     ArrayFill(warr,0,arrLen,0);
     for(int i = SqrtPeriod * factor; i >= 1; i--)
       {
        double halfma = iMA(NULL, TimeFrame, HalfPeriod, 0, MODE_LWMA, maprice, i + shift+1);
        double fullma = iMA(NULL, TimeFrame, period, 0, MODE_LWMA, maprice, i + shift+1);
        warr[i] = 2.0 *  halfma - fullma;
       }
       */
   double ma1 = iMAOnArray(warr, 0, SqrtPeriod, 0, MODE_LWMA, 1);

   ret=ma0;
   if(filter > 0)
     {
      if(MathAbs(ma0 - ma1) < filter * Point)
         ret = ma1;
     }

   return ret;
  }
//+------------------------------------------------------------------+
double iHullEAx(string symbol, int TimeFrame, int maprice, int period, double divisor, int shift)
  {
   int HalfPeriod = MathFloor(period / divisor);
   int SqrtPeriod = MathFloor(MathSqrt(period));
   int factor=1;
//--- hull moving average 1st buffer

   double warr[];
   ArraySetAsSeries(warr, true);
   ArrayResize(warr, SqrtPeriod * factor + 1);


   for(int i = SqrtPeriod * factor; i >= 0; i--)
     {
      warr[i] = 2.0 * iMA(NULL, TimeFrame, HalfPeriod, 0, MODE_LWMA, maprice, i + shift) - iMA(NULL, TimeFrame, period, 0, MODE_LWMA, maprice, i + shift);
     }
   double ret = iMAOnArray(warr, 0, SqrtPeriod, 0, MODE_SMA, 0);
   return ret;
  }
//+------------------------------------------------------------------+
