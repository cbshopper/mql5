//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
//#define TESTING

#include <CB/CB_Draw.mqh>
#include "common/CBcExpert.mqh"
#include "common/CBEABody.mqh"
//#define TESTING
#define EXPERT
input  string SPEZIFIC = "--------  EA Settings -------------";
input int MagicNumber = 220218;
input int    TrailingStop = 0;
input int    StopLoss = 0;
input int    TakeProfit = 0;
input int    MaxBuyOrder = 1;
input int    MaxSellOrder = 1;

#include "signals/Validator2.mqh"

ENUM_TIMEFRAMES      period = PERIOD_CURRENT;      // timeframe


int cust_ptr = 0;


CcbExpert  *cbexpert;
CValidator2 *indicator;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Expert_OnInit(CcbExpert *expert)
  {
   indicator = new CValidator2();
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
int GetOpenSignal2(int shift)
  {
   int signal = 0;
   bool enable_sell = false;
   bool enable_buy = false;
   double buy0  =  indicator.OpenBuy(shift);
   double sell0  =  indicator.OpenSell(shift);
   double ma10 = indicator.MA1Value(shift);
   double ma20 = indicator.MA2Value(shift);
   double ma11 = indicator.MA1Value(shift+1);
   double ma21 = indicator.MA2Value(shift+1);


   DrawDot("ma1",shift,ma10);
   
  // DrawIndicator("HULL",shift,val,true,clrBlue);
   
  // Print(__FUNCTION__,"***** MA1=",ma1," MA2=",ma2,"  buy0=",buy0," sell0=",sell0);
  /*
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
     */
    
   enable_buy= ma10 > ma20 && ma11 < ma21;
   enable_sell= ma10 < ma20 && ma11 > ma21;  
     
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
int GetOpenSignal(int shift) 
  {
   int signal = 0;
   bool enable_sell = false;
   bool enable_buy = false;
   double buy0  =  indicator.OpenBuy(shift);
   double sell0  =  indicator.OpenSell(shift);
    DrawDot("BUY",shift,buy0,clrBlue);
     DrawDot("SELL",shift,sell0,clrRed);
 
    buy0 = EmptyToZero2(buy0);
    sell0 = EmptyToZero2(sell0);
     Print(__FUNCTION__, TimeAsString(shift),"  buy0=",buy0," sell0=",sell0);
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
int GetCloseSignal2(int shift, int mode,  int ticket)
  {

   if(TrailingStop > 0)
      cbexpert.SetTrailingStop(TrailingStop);
// return 0;  ///// AUS!!!-----------------------------------------------------
   int ret = 0;
   /*
   double buy0  =  indicator.CloseBuy(shift);
   double sell0  =  indicator.CloseSell(shift);
   buy0 = EmptyToZero2(buy0);
   sell0 = EmptyToZero2(sell0);
   */
   double ma10 = indicator.MA1Value(shift);
   double ma20 = indicator.MA2Value(shift);
   double ma11 = indicator.MA1Value(shift+1);
   double ma21 = indicator.MA2Value(shift+1);

   bool close_sell = ma10 > ma20 && ma11 < ma21;
   bool close_buy = ma10 < ma20 && ma11 > ma21;  
   
   if(mode == OP_BUY && close_buy)
     {
      ret = 1;
     }
   if(mode == OP_SELL && close_sell)
     {
      ret = 1;
     }
   if (ret != 0) Print("<<<<<<<<<<< ", __FUNCTION__, "  close_buy=", close_buy, " close_sell=", close_sell, " ret=", ret);
   return ret;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetCloseSignal(int shift, int mode,  int ticket) 
  {

   if(TrailingStop > 0)
      cbexpert.SetTrailingStop(TrailingStop);
// return 0;  ///// AUS!!!-----------------------------------------------------
   int ret = 0;
   double cbuy  =  indicator.CloseBuy(shift);
   double csell  =  indicator.CloseSell(shift);
   DrawDot("BUY",shift,cbuy,clrBlue,120);
   DrawDot("SELL",shift,csell,clrRed,120);
   

   
   cbuy = EmptyToZero2(cbuy);
   csell = EmptyToZero2(csell);
   Print(__FUNCTION__, TimeAsString(shift), "  cbuy=",cbuy," csell=",csell);
   
   if(mode == OP_SELL && csell > 0)
     {
      ret = 1;
     }
   if(mode == OP_BUY && cbuy > 0)
     {
      ret = 1;
     }
   if (ret != 0) Print("<<<<<<<<<<< ", __FUNCTION__, "  cbuy=", cbuy, " csell=", csell, " ret=", ret);
   return ret;
  }
  int GetCloseSignal(int shift, int mode,  int ticket) 
  {

   if(TrailingStop > 0)
      cbexpert.SetTrailingStop(TrailingStop);
// return 0;  ///// AUS!!!-----------------------------------------------------
   int ret = 0;
   datetime opentime = cbexpert.Ordermachine.PositionOpenTime(ticket);
   int openbar = iBarShift(NULL,0,opentime,false);
   if (openbar - shift > 5) ret=1;
    return ret;
  }