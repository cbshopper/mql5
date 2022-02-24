//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <cb\CB_CheckGap.mqh>
#include <cb\CB_IMAX.mqh>
#define FILTER1

input string __FILTER_SETTINGS_ = " ================== FILTER SETTINGS ==================";
input bool check_Trend = false;
input ENUM_MMA_METHOD Trend_method = MMODE_EMA;
ENUM_APPLIED_PRICE Trend_price = PRICE_OPEN;
input int    Trend_period = 100;
input int    Trend_mindiff = 0;

#ifdef FILTER_MACD
input bool check_MacdDiv =true;
input int macd_fastperiod=12;
input int macd_slowperiod=26;
input int macd_signal=9;
input int macd_minpoints=5;
#endif
#ifdef FILTER2
//#include "CB_uniFilter2.mqh"
input string __FILTEREXTAS_SETTINGS_ = " ---------------- FILTEREXTRAS SETTINGS -------------------";
input int    Distance2StopMa=25;    //Distance in Point()s
#endif

double trend0=0;
double trend1=0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int FilterSignal(int signal,  int shift)
  {
   bool enable_buy = signal > 0;
   bool enable_sell = signal < 0;
   int ret = FilterSignal(enable_buy,enable_sell,trend0,trend1,shift);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int FilterSignal(bool &enable_buy, bool &enable_sell, double trend0, double trend1, int shift)
  {
   int ret = 0;

   if(enable_buy || enable_sell)
     {
      if(Trend_period>0)
        {
         if(check_Trend)    // same as over_under ....
           {
            enable_buy = enable_buy &&  trend0 > trend1 ;
            enable_sell = enable_sell && trend0 < trend1 ;
           }
         if(Trend_mindiff > 0)
           {
            bool trend_ok = MathAbs(trend0-trend1) > Trend_mindiff*Point();
            enable_buy = enable_buy &&  trend_ok;
            enable_sell = enable_sell && trend_ok;
           }
        }
      if(enable_buy || enable_sell)
        {
         if(CheckGap(5,shift))
           {
            enable_buy=false;
            enable_sell=false;
           }
        }
#ifdef FILTER_MACD
      if(enable_buy || enable_sell)
        {
         if(check_MacdDiv)
           {
            double macd0 = iMACD(NULL,0,macd_fastperiod,macd_slowperiod,macd_signal,PRICE_CLOSE,MODE_MAIN,shift)/Point();
            double macd1 = iMACD(NULL,0,macd_fastperiod,macd_slowperiod,macd_signal,PRICE_CLOSE,MODE_MAIN,shift+1)/Point();
            double sig0 = iMACD(NULL,0,macd_fastperiod,macd_slowperiod,macd_signal,PRICE_CLOSE,MODE_SIGNAL,shift)/Point();
            double sig1 = iMACD(NULL,0,macd_fastperiod,macd_slowperiod,macd_signal,PRICE_CLOSE,MODE_SIGNAL,shift+1)/Point();

            enable_buy = enable_buy && macd0>macd1 && macd0 > 0 && sig0 > sig1; // macd_minpoints;
            enable_sell= enable_sell && macd0<macd1 && macd0 < 0 && sig0 < sig1; //macd_minpoints;
           }
        }
#endif

#ifdef FILTER2
      //  ret = FilterSignalExtras(enable_buy,enable_sell,trend0,trend1,shift);
      if(enable_buy || enable_sell)
        {
         double price =Open[shift];
         double ma = iMAX(stopma_period,stopma_method,stopma_price,shift);


         if(Distance2StopMa>0)
           {
            enable_buy = enable_buy && price < ma + Distance2StopMa*Point();
            enable_sell = enable_sell &&  price > ma -  Distance2StopMa*Point();
            Print(__FUNCTION__,":  price < ma + Distance2StopMa*Point()=", price < ma + Distance2StopMa*Point()," price > ma -  Distance2StopMa*Point()=",price > ma -  Distance2StopMa*Point());
           }
        }
#endif
#ifdef RANGEFILTERS
      //     FilterSignalRange(enable_buy,enable_sell,shift);
#endif


     }
   if(enable_buy)
      ret = 1;
   if(enable_sell)
      ret = -1;

   return ret;
  }
//+------------------------------------------------------------------+
