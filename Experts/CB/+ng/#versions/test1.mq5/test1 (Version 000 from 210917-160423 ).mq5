//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
//#define TESTING

#include <CB/hullMA.mqh>
#include "common/CBcExpert.mqh"
#include "common/CBEABody.mqh"

#define EXPERT
input  string SPEZIFIC = "--------  EA Settings -------------";
input int MagicNumber = 20032201;
input int    TrailingStop = 0;
input int    StopLoss = 0;
input int    TakeProfit = 0;
input int    MaxBuyOrder = 10;
input int    MaxSellOrder = 10;

input string INDICATOR_PARAMETR = "------- Indicator Parameter --------";
input int    MAPeriod = 40; // MA Period for Hull & Band
input int    TriggerPeriod = 10; // Trigger-Period
input int    TriggerPeriodDelta = 2; // Trigger-Period Delta
input double Divisor = 2.0;
input double Deviation = 1.0;
input int    MinDiff = 1;



int    StdDevPeriod = MAPeriod; //10;

CHull HullMA;
CHull TriggerMA;
CHull TrendMA;
int strdev_ptr = 0;
int atr_ptr = 0;
int trend_ptr = 0;
int hull_ptr = 0;
int cust_ptr = 0;

double trigger1 = 0;
double trend1 = 0;
double up1 = 0;
double lo1 = 0;
double ma1 = 0;
double ma2 = 0;

CcbExpert  *myexpert;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Expert_OnInit(CcbExpert *expert)
  {
//  HullMA.init(MAPeriod, Divisor, PRICE_CLOSE);
//  TriggerMA.init(TriggerPeriod, TriggerDivisor, PRICE_CLOSE);
//   TrendMA.init(TrendPeriod, Divisor, PRICE_CLOSE);
//   strdev_ptr = iStdDev(NULL, PERIOD_CURRENT, StdDevPeriod, 0, MODE_EMA, PRICE_CLOSE);
// atr_ptr = iATR(NULL, PERIOD_CURRENT, 48);
//   trend_ptr = iDEMA(NULL, PERIOD_CURRENT, TrendPeriod, 0, PRICE_CLOSE);
//   hull_ptr = iCustom(NULL, PERIOD_CURRENT, "CB/ma/CB_Hull", MAPeriod, 0, PRICE_CLOSE, Divisor, 0, 1, 0);
   cust_ptr = iCustom(NULL, PERIOD_CURRENT, "CB/ma/CB_HullBollinger", MAPeriod, TriggerPeriod, TriggerPeriodDelta, Divisor, Deviation, MinDiff);
   expert.SetMaxSpread(100);
   expert.SetStopLossTicks(StopLoss);
   expert.SetMaxBuyPositions(MaxBuyOrder);
   expert.SetMaxSellPositions(MaxSellOrder);
   expert.SetMaxBuyOrders(MaxBuyOrder);
   expert.SetMaxSellOrders(MaxSellOrder);
   expert.SetPendingOrderExpireBarCount(100);
   expert.SetStopLossTicks(TrailingStop);
   myexpert = expert;
   return INIT_SUCCEEDED;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetOpenSignal(int shift)
  {
   int signal = 0;
   bool enable_sell = false;
   bool enable_buy = false;
//double ma =  GetIndicatorBufferValue(cust_ptr, shift, 0);
   double up0 = GetIndicatorBufferValue(cust_ptr, shift, 1);
   double lo0 = GetIndicatorBufferValue(cust_ptr, shift, 2);
//double trigger0 =  GetIndicatorBufferValue(cust_ptr, shift, 3);
   double sigbuy = GetIndicatorBufferValue(cust_ptr, shift, 5);
   double sigsell = GetIndicatorBufferValue(cust_ptr, shift, 6);
   enable_buy = sigbuy > 0;
   enable_sell = sigsell > 0;
   if(enable_buy || enable_sell)
      Print(__FUNCTION__, " sigbuy=", sigbuy, " sigsell=", sigsell);
   int sl = (up0 - lo0) / Point();
   int tp =  sl;
   if(enable_buy)
     {
      signal = 1;
      myexpert.SetOrderValues(signal, MODE_MARKET, 0,  sl, tp);
      //   myexpert.CloseAllPositions(POSITION_TYPE_SELL);
     }
   if(enable_sell)
     {
      signal = -1;
      myexpert.SetOrderValues(signal, MODE_MARKET, 0, sl, tp);
      //    myexpert.CloseAllPositions(POSITION_TYPE_BUY);
     }
   return signal;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetCloseSignal(int shift, int mode,  int ticket)
  {
   return 0;  ///// AUS!!!
   
   int ret = 0;
//  Print(__FUNCTION__);
   double up0 = GetIndicatorBufferValue(cust_ptr, shift, 1);
   double lo0 = GetIndicatorBufferValue(cust_ptr, shift, 2);
   up0 = NormalizeDouble(up0, 3);
   lo0 = NormalizeDouble(lo0, 3);
   /*
   if(TrailingStop > 0)
      myexpert.SetTrailingStop(TrailingStop);
   double tp = 0;
   double sl = 0;
   tp = CheckTPPrice(up0 + TakeProfit * Point(), ORDER_TYPE_BUY, 0);
   // sl=CheckSLPrice(lo0,ORDER_TYPE_BUY,0);
   myexpert.PositionsModify(POSITION_TYPE_BUY, sl, tp);
   tp = CheckTPPrice(lo0 - TakeProfit * Point(), ORDER_TYPE_SELL, 0);
   //  sl=CheckSLPrice(up0,ORDER_TYPE_SELL,0);
   myexpert.PositionsModify(POSITION_TYPE_SELL, sl, tp);
   */
   datetime  opentime = myexpert.OrderMachine.PositionOpenTime(ticket);
   datetime  now = iTime(NULL, PERIOD_CURRENT, shift);
   if(now - opentime > 5 * PeriodSeconds())
     {
      double price = iClose(NULL, PERIOD_CURRENT, shift); //SymbolInfoDouble(Symbol(), SYMBOL_ASK);
      //    Print(__FUNCTION__, "******** mode=", mode, " price=", price, " lo=", lo0, " up=", up0);
      if(price > up0)
         ret = 1;
      if(price < lo0)
         ret = 1;
     }
   return ret;
  }



//+------------------------------------------------------------------+
