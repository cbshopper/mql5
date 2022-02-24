//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
//#define TESTING

//#include <CB/hullMA.mqh>
#include <CB/CB_Draw.mqh>
#include "common/CBcExpert.mqh"
#include "common/CBEABody.mqh"
//#define TESTING
#define EXPERT
input  string SPEZIFIC = "--------  EA Settings -------------";
input int    MagicNumber = 220218;
input int    TrailingStop = 0;
input int    StopLoss = 0;
input int    TakeProfit = 0;
input int    MaxBuyOrder = 1;
input int    MaxSellOrder = 1;

#include "signals/Validator.mqh"

ENUM_TIMEFRAMES      period = PERIOD_CURRENT;      // timeframe


int cust_ptr = 0;


CcbExpert  *cbexpert;
CValidator *indicator;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Expert_OnInit(CcbExpert *expert)
  {
   indicator = new CValidator();
   indicator.Init();
   expert.SetMaxSpread(100);
 //  expert.SetStartShift(1);
//  expert.SetStopLossTicks(StopLoss);
   expert.SetMaxBuyPositions(MaxBuyOrder);
   expert.SetMaxSellPositions(MaxSellOrder);
   expert.SetMaxBuyOrders(MaxBuyOrder);
   expert.SetMaxSellOrders(MaxSellOrder);
   expert.SetPendingOrderExpireBarCount(100);
  // expert.SetEtheryTick(false);
   cbexpert = expert;
   return INIT_SUCCEEDED;
  }

#define NULLVAL EMPTY_VALUE
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetOpenSignal(int shift) 
  {
   int signal = 0;
   bool enable_sell = false;
   bool enable_buy = false;
   double buy0  =  indicator.OpenBuy(shift);
   double sell0  =  indicator.OpenSell(shift);
   double val = indicator.HullValue(shift);
   double uptrend = indicator.UpValue(shift);
  // DrawIndicator("HULL",shift,val,true,clrBlue);
   DrawDot("HULL",shift,val);
  // Print(__FUNCTION__,"***** HULL=",val," UpTrend=",uptrend,"  buy0=",buy0," sell0=",sell0);
   buy0 = EmptyToZero2(buy0);
   sell0 = EmptyToZero2(sell0);
 //  Print(__FUNCTION__,"***** buy0=",buy0," sell0=",sell0);
   if(buy0 > 0)
     {
      enable_buy = true;
  //      DrawIndicator("BUY",shift,buy0,true,clrBlue);
     }
   if(sell0 > 0)
     {
      enable_sell = true;
  //    DrawIndicator("SELL",shift,sell0,true,clrBlue);
     }
   int sl = StopLoss;
   int tp = TakeProfit;
   if(enable_buy || enable_sell)
     {
 //     Print(__FUNCTION__, "*******************  buy0=", buy0, " sell0=", sell0);
      Print(">>>>>>>>>> "__FUNCTION__," buy0=", buy0, " sell0=", sell0, " enable_buy=", enable_buy, " enable_sell=", enable_sell, " sl=", sl, " tp=", tp);
     }
   if(enable_buy)
     {
      signal = 1;
      cbexpert.SetOrderValues(ORDER_TYPE_BUY, 0,  sl, tp);
      //   cbexpert.CloseAllPositions(POSITION_TYPE_SELL);
     }
   if(enable_sell)
     {
      signal = -1;
      cbexpert.SetOrderValues(ORDER_TYPE_SELL, 0, sl, tp);
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
   double buy0  =  indicator.CloseBuy(shift);
   double sell0  =  indicator.CloseSell(shift);
   buy0 = EmptyToZero2(buy0);
   sell0 = EmptyToZero2(sell0);
   if(mode == OP_SELL && buy0 > 0)
     {
      ret = 1;
     }
   if(mode == OP_BUY && sell0 > 0)
     {
      ret = 1;
     }
   if (ret != 0) Print("<<<<<<<<<<< ", __FUNCTION__, "  buy0=", buy0, " sell0=", sell0, " ret=", ret);
   return ret;
  }
//+------------------------------------------------------------------+
