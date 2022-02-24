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
input int    MinBarBeforeClose = 5;
input int    mytakeprofit=500;
input int    mystoploss=30;

#include "signals/STORSI.mqh"

input int                  ma_period = 7;               // period of ma
input int                  ma_shift = 0;                 // shift
input ENUM_MA_METHOD       ma_method = MODE_EMA;         // type of smoothing
input ENUM_APPLIED_PRICE   applied_price = PRICE_CLOSE;  // type of price
ENUM_TIMEFRAMES      period = PERIOD_CURRENT;      // timeframe


int cust_ptr = 0;


CcbExpert  *cbexpert;
CStochRSI *indicator;
int  ma_handle;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Expert_OnInit(CcbExpert *expert)
  {
   indicator = new CStochRSI();
   indicator.Init();
   ma_handle = iMA(NULL, period, ma_period, ma_shift, ma_method, applied_price);
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
   double ma0 =  GetIndicatorBufferValue(ma_handle, shift, 0);
   double sto0  =  indicator.Value(shift + 0);
   double sto1  =  indicator.Value(shift + 1);
   double sto_sig0  =  indicator.Signal(shift + 0);
   double sto_sig1  =  indicator.Signal(shift + 1);
   enable_buy = sto0 > sto_sig0 && sto1 < sto_sig1 && sto0 < 20;
   enable_sell = sto0 < sto_sig0 && sto1 > sto_sig1 && sto0 > 80;
   int sl = StopLoss;
   int tp = TakeProfit;
   if(enable_buy || enable_sell)
      Print(__FUNCTION__, " enable_buy=", enable_buy, " enable_sell=", enable_sell, " sl=", sl, " tp=", tp);
   if(enable_buy)
     {
      signal = 1;
      cbexpert.SetOrderValues(ORDER_TYPE_BUY_STOP, ma0,  sl, tp);
      //   cbexpert.CloseAllPositions(POSITION_TYPE_SELL);
     }
   if(enable_sell)
     {
      signal = -1;
      cbexpert.SetOrderValues(ORDER_TYPE_SELL_STOP, ma0, sl, tp);
      //    cbexpert.CloseAllPositions(POSITION_TYPE_BUY);
     }
   return signal;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetCloseSignalV2(int shift, int mode,  int ticket)
  {
   if(TrailingStop > 0)
      cbexpert.SetTrailingStop(TrailingStop);
   int ret = 0;
//  Print(__FUNCTION__);
   double win = cbexpert.OrderMachine.PositionProfit(ticket);
   if(StopLoss == 0 && TakeProfit == 0)
     {
      if(win > mytakeprofit * Point() || win < mystoploss * Point())
        {
         ret = 1;
        }
     
     }
      return ret;
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
  double stop, take;



   ENUM_POSITION_TYPE type = cbexpert.OrderMachine.PositionType(ticket);
   datetime  opentime = cbexpert.OrderMachine.PositionOpenTime(ticket);
   datetime  now = iTime(NULL, PERIOD_CURRENT, shift+1);
   if(now - opentime > MinBarBeforeClose * PeriodSeconds())
     {
   
   double stop  = mystoploss*Point();
   double take =mytakeprofit*Point();
   double ask = Ask();
   double bid = Bid();
   double pos_price = cbexpert.OrderMachine.PositionOpenPrice(ticket);
     
   if (type == POSITION_TYPE_BUY)
   {
      stop = NormalizeDouble(pos_price-stop,3);
      take = NormalizeDouble(pos_price+take,3);
      if (bid > take || bid < stop ) ret=1;
    }
   else
   {
      stop = NormalizeDouble(pos_price+stop,3);
      take = NormalizeDouble(pos_price-take,3);
      if (ask > take || ask < stop ) ret=1;
   }
   
   } 
   return ret;
  }
