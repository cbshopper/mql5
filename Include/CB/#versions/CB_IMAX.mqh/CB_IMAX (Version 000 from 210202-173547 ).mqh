//+------------------------------------------------------------------+
//|                                                      CB_IMAX.mqh |
//|                                                   Christof blank |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Christof Blank"
#include "..\..\Indicators\cb\Ma\hullMA.mqh"
//#include "..\Indicators\TMA\tma.mqh"

enum ENUM_MMA_METHOD
  {
   MMODE_SMA=0,
   MMODE_EMA=1,
   MMODE_SMMA =2,
   MMODE_LWMA = 3,
   MMODE_HULLMA=4,
   MMODE_TMA=5
  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void iMaxInit()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void iMaxDeInit()
  {
  }
  
CHull iHull;  
int hull_last_period=0;
int hull_last_price=0;



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iMAX(int period, int method,ENUM_APPLIED_PRICE price, int shift)
  {
   double val = 0;
   
//val = iMA(NULL, 0, period, 0, Trend_method, PRICE_OPEN, shift);
   switch(method)
     {
      case MMODE_EMA:
      case MMODE_SMA:
      case MMODE_LWMA:
      case MMODE_SMMA:
         val = iMA(NULL,0,period,0,method,price,shift);
         break;

      case MMODE_HULLMA:
      
         if(period != hull_last_period || price != hull_last_price)
           {
            iHull.init(period,2.0,price);
            hull_last_period=period;
            hull_last_price=price;
           }
    //     val = iHull.calculate(shift);
    
          val= iHullEA(NULL,0,price,period,2.0,shift);
         break;
     // case MMODE_TMA:
     //    val  = iTma(iMA(NULL,0,1,0,MODE_SMA,price,shift),period,shift);
     //    break;
     }

   return val;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iMAX(int period, int method, ENUM_APPLIED_PRICE price, int filter, int shift, int instance)
  {

   double ret = iMAX(period,method,price,shift);
   if(filter > 0)
     {
      double lastval = iMAX(period,method,price,shift+1);

      if(MathAbs(ret - lastval)< filter * Point)
        {
         ret = lastval;
        }
     }
   return ret;
  }
/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iMAXSm(int period, int method,int price,  int shift)
  {
   double arr[];

   ArrayResize(arr,period);
   ArraySetAsSeries(arr,true);
   for(int i = 0; i < period; i++)
     {
      arr[i] = iMAX(period,method,price,shift+i);
     }
   double ma0 = iMAOnArray(arr,0,period,0,MODE_SMA,0);
   return ma0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iMAXSmF(int period, int method,int price, int filter,int offset, int shift)
  {
   double arr[];

   ArrayResize(arr,period+offset);
   ArraySetAsSeries(arr,true);
   for(int i = 0; i < period+offset; i++)
     {
      arr[i] = iMAX(period,method,price,shift+i);
     }
   double ma1 = iMAOnArray(arr,0,period,0,MODE_SMA,offset);
   double ma0 = iMAOnArray(arr,0,period,0,MODE_SMA,0);
   if(MathAbs(ma0 - ma1) > filter*Point)
     {
      return ma0;
     }
   else
     {
      return ma1;
     }
  }

double ___lastval[];
datetime __lasttime[];
//+------------------------------------------------------------------+
double iMaxTrend(int period, int method,int price, int filter, int shift, int instance)
  {
   double ret=0;
   if(ArraySize(___lastval) < instance+1)
     {
      ArrayResize(___lastval,instance+1);
      ArrayResize(__lasttime,instance+1);
     }
   double val = iMAX(period,method,price,shift);
   if(MathAbs(val-___lastval[instance]) > filter*Point)
     {
      ret =val;
      ___lastval[instance] =val;
      __lasttime[instance] = Time[shift];
     }
   else
     {
      int n;
      for(n = 1; shift+n < Bars-1 && Time[shift+n] >= __lasttime[instance]; n++)
         continue;
      ret =  val + (val-___lastval[instance])/n;
      ret = ___lastval[instance];
     }
   return ret;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
*/
