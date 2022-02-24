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
input double TPFactor = 2.0;
input int    TrailingStop = 0;
input int    StopLoss = 0;
input int    TakeProfit = 0;
input int    MaxBuyOrder = 10;
input int    MaxSellOrder = 10;
input int    MinBarBeforeClose=5;

#include "signals/HullBollinger.mqh"




int cust_ptr = 0;


CcbExpert  *cbexpert;
CHullBollinger *indicator;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Expert_OnInit(CcbExpert *expert)
  {
   indicator = new CHullBollinger();
   indicator.Init();
   expert.SetMaxSpread(100);
//  expert.SetStopLossTicks(StopLoss);
   expert.SetMaxBuyPositions(MaxBuyOrder);
   expert.SetMaxSellPositions(MaxSellOrder);
   expert.SetMaxBuyOrders(MaxBuyOrder);
   expert.SetMaxSellOrders(MaxSellOrder);
   expert.SetPendingOrderExpireBarCount(100);
   cbexpert = expert;
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
   double up0 = indicator.UpperBand(shift);
   double lo0 = indicator.LowerBand(shift);
//double trigger0 =  GetIndicatorBufferValue(cust_ptr, shift, 3);
   double sigbuy = indicator.BuySignal(shift);
   double sigsell = indicator.SellSignal(shift);
   enable_buy = sigbuy > 0;
   enable_sell = sigsell > 0;
  
   int sl = (int)((up0 - lo0) / Point());
   int tp = (int)( sl * TPFactor );
   sl = StopLoss;
   tp = TakeProfit;
    if(enable_buy || enable_sell)
      Print(__FUNCTION__, " sigbuy=", sigbuy, " sigsell=", sigsell," sl=",sl, " tp=",tp);
   if(enable_buy)
     {
      signal = 1;
      cbexpert.SetOrderValues(signal, MODE_STOP, lo0,  sl, tp);
      //   cbexpert.CloseAllPositions(POSITION_TYPE_SELL);
     }
   if(enable_sell)
     {
      signal = -1;
      cbexpert.SetOrderValues(signal, MODE_STOP, up0, sl, tp);
      //    cbexpert.CloseAllPositions(POSITION_TYPE_BUY);
     }
   return signal;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetCloseSignal(int shift, int mode,  int ticket)
  {
   if(TrailingStop > 0)
      cbexpert.SetTrailingStop(TrailingStop);
  
  
  // return 0;  ///// AUS!!!-----------------------------------------------------
   
   
   
   int ret = 0;
//  Print(__FUNCTION__);
   double up0 = indicator.UpperBand(shift);
   double lo0 = indicator.LowerBand(shift);
   up0 = NormalizeDouble(up0, 3);
   lo0 = NormalizeDouble(lo0, 3);
   
   cbexpert.OrdersModify(ORDER_TYPE_BUY,lo0,0,0,0);
   cbexpert.OrdersModify(ORDER_TYPE_SELL,up0,0,0,0);
   /*

   */
   datetime  opentime = cbexpert.OrderMachine.PositionOpenTime(ticket);
   datetime  now = iTime(NULL, PERIOD_CURRENT, shift+1);
   if(now - opentime > MinBarBeforeClose * PeriodSeconds())
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
