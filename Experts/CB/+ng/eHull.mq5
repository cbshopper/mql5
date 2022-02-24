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
input int MagicNumber = 220218;
input int    TrailingStop = 0;
input int    StopLoss = 0;
input int    TakeProfit = 0;
input int    MaxBuyOrder = 1;
input int    MaxSellOrder = 1;

#include "signals/HullCustom.mqh"

ENUM_TIMEFRAMES      period = PERIOD_CURRENT;      // timeframe


int cust_ptr = 0;


CcbExpert  *cbexpert;
CHullCustom *indicator;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Expert_OnInit(CcbExpert *expert)
  {
   indicator = new CHullCustom();
   indicator.Init();
   expert.SetMaxSpread(100);
//  expert.SetStopLossTicks(StopLoss);
   expert.SetMaxBuyPositions(MaxBuyOrder);
   expert.SetMaxSellPositions(MaxSellOrder);
   expert.SetMaxBuyOrders(MaxBuyOrder);
   expert.SetMaxSellOrders(MaxSellOrder);
   expert.SetPendingOrderExpireBarCount(100);
    expert.SetEtheryTick(true);
    expert.SetStartShift(1);
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
   
   
   double hull9  =  indicator.HullValue(shift + 0);
   double hull1  =  indicator.HullValue(shift + 1);
   double up0  =  indicator.UpValue(shift + 0);
   double up1  =  indicator.UpValue(shift + 1);
   
   
  if(up0 != EMPTY_VALUE && up1 == EMPTY_VALUE)
      {
         enable_buy=true;
      }
      if(up0 == EMPTY_VALUE && up1 != EMPTY_VALUE)
      {
       enable_sell=true;
      }
   
   
   
   int sl = StopLoss;
   int tp = TakeProfit;
   
   
   
   
   
   if(enable_buy || enable_sell)
      Print(__FUNCTION__, " enable_buy=", enable_buy, " enable_sell=", enable_sell, " sl=", sl, " tp=", tp);
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
  
   double hull9  =  indicator.HullValue(shift + 0);
   double hull1  =  indicator.HullValue(shift + 1);
   double up0  =  indicator.UpValue(shift + 0);
   double up1  =  indicator.UpValue(shift + 1);



   ENUM_POSITION_TYPE type = cbexpert.OrderMachine.PositionType(ticket);
    
    if(up0 != EMPTY_VALUE && up1 == EMPTY_VALUE)
      {
         if (type == POSITION_TYPE_SELL) ret=1;
      }
      if(up0 == EMPTY_VALUE && up1 != EMPTY_VALUE)
      {
        if (type == POSITION_TYPE_BUY) ret=1;
      }

   return ret;
  }
