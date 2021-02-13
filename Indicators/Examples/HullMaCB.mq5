//------------------------------------------------------------------

#property copyright "mladen"
#property link      "www.forex-tsd.com"

//------------------------------------------------------------------

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1

#property indicator_label1  "Hull"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrLimeGreen,clrPaleVioletRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//

#include <cb\CB_getprice.mqh>
//

input int       HullLength  = 27;       // Hull MA calculaion period
input enPrices  Price       = pr_close; // Price to use
input double    HullDivisor = 1.5;      // Hull calculation "speed"

//

double hull[];
double colorBuffer[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,hull,INDICATOR_DATA);
   SetIndexBuffer(1,colorBuffer,INDICATOR_COLOR_INDEX);


   IndicatorSetString(INDICATOR_SHORTNAME," Hull trend ("+string(HullLength)+")");
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {

   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total; i++)
     {
      double price =getPrice(Price,open,close,high,low,i,rates_total);
      hull[i] = iHull(price,HullLength,HullDivisor,i,rates_total,0);
      if(i>0)
        {
         colorBuffer[i] = colorBuffer[i-1];
         if(hull[i] > hull[i-1])
            colorBuffer[i]= 0;
         if(hull[i] < hull[i-1])
            colorBuffer[i]= 1;
        }
     }
   return(rates_total);
  }










double workHull[][2];
double iHull(double price, double period, double divisor, int r, int total, int instanceNo=0)
  {
   if(ArrayRange(workHull,0)!= total)
      ArrayResize(workHull,total);

   int HmaPeriod  = (int)MathMax(period,2);
   int HalfPeriod = (int)MathFloor(HmaPeriod/divisor);
   int HullPeriod = (int)MathFloor(MathSqrt(HmaPeriod));
   double weight;
   instanceNo *= 2;

   workHull[r][instanceNo] = price;


   double hmw = HalfPeriod;
   double hma = hmw*price;
   for(int k=1; k<HalfPeriod && (r-k)>=0; k++)
     {
      weight = HalfPeriod-k;
      hmw   += weight;
      hma   += weight*workHull[r-k][instanceNo];
     }
   workHull[r][instanceNo+1] = 2.0*hma/hmw;

   hmw = HmaPeriod;
   hma = hmw*price;
   for(int k=1; k<period && (r-k)>=0; k++)
     {
      weight = HmaPeriod-k;
      hmw   += weight;
      hma   += weight*workHull[r-k][instanceNo];
     }
   workHull[r][instanceNo+1] -= hma/hmw;


   hmw = HullPeriod;
   hma = hmw*workHull[r][instanceNo+1];
   for(int k=1; k<HullPeriod && (r-k)>=0; k++)
     {
      weight = HullPeriod-k;
      hmw   += weight;
      hma   += weight*workHull[r-k][1+instanceNo];
     }
   return(hma/hmw);
  }
//+------------------------------------------------------------------+
