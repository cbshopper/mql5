//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2020, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
//#define TESTING

//#include <CB/hullMA.mqh>
#include "common/CBcExpert.mqh"
#include "common/CBEABody.mqh"
#include <Expert\Signal\SignalLaquerre.mqh>

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
int    mytakeprofit = 500;
int    mystoploss = 30;

#include "signals/sLAQ.mqh"
input double               gamma_open = 0.9;
input double               gamma_close = 0.9;
input int HighLevel_open = 75;
input int LowLevel_open = 15;
input int HighLevel_close = 75;
input int LowLevel_close = 15;

input int                  maopen_period = 7;               // open period of ma
int                  maopen_shift = 0;                 // shift
ENUM_MA_METHOD       maopen_method = MODE_EMA;         // open ma type of smoothing
int                  maclose_period = 7;               // close period of ma
int                  maclose_shift = 0;                 // shift
ENUM_MA_METHOD       maclose_method = MODE_EMA;         // close ma type of smoothing

ENUM_APPLIED_PRICE   applied_price = PRICE_CLOSE;  // type of price
ENUM_TIMEFRAMES      period = PERIOD_CURRENT;      // timeframe



CcbExpert  *cbexpert;
CLaq *indicator;
CLaq *closeindicator;
int  maopen_handle;
int maclose_handle;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Expert_OnInit(CcbExpert *expert)
   {
    indicator = new CLaq;
    if(!indicator.Init(gamma_open,HighLevel_open,LowLevel_open))
        return INIT_FAILED;
    
    closeindicator = new CLaq;
    if(!closeindicator.Init(gamma_close,HighLevel_close,LowLevel_close))
        return INIT_FAILED;

    maopen_handle = iMA(NULL, period, maopen_period, maopen_shift, maopen_method, applied_price);
    maclose_handle = iMA(NULL, period, maclose_period, maclose_shift, maclose_method, applied_price);
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



    double ma0 =  GetIndicatorBufferValue(maopen_handle, shift, 0);


    signal = indicator.GetSignal(shift);
//  ma0=0;

    int sl = StopLoss;
    int tp = TakeProfit;
    if(signal != 0)
        Print(__FUNCTION__, " signal=", signal, " sl=", sl, " tp=", tp);
    if(signal > 0)
       {
        cbexpert.SetOrderValues(ORDER_TYPE_BUY_STOP, ma0,  sl, tp);
        //      cbexpert.SetOrderValues(ORDER_TYPE_BUY, ma0,  sl, tp);
        //   cbexpert.CloseAllPositions(POSITION_TYPE_SELL);
       }
    if(signal < 0)
       {
        //     cbexpert.SetOrderValues(ORDER_TYPE_SELL, ma0, sl, tp);
        cbexpert.SetOrderValues(ORDER_TYPE_SELL_STOP, ma0, sl, tp);
        //    cbexpert.CloseAllPositions(POSITION_TYPE_BUY);
       }
    return signal;
   }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetCloseSignalxxint(int shift, int mode,  int ticket)
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
    double ma0 =  GetIndicatorBufferValue(maclose_handle, shift, 0);
    ENUM_POSITION_TYPE type = cbexpert.OrderMachine.PositionType(ticket);
    datetime  opentime = cbexpert.OrderMachine.PositionOpenTime(ticket);
    datetime  now = iTime(NULL, PERIOD_CURRENT, shift + 1);
    if(now - opentime > MinBarBeforeClose * PeriodSeconds())
       {

        // ret = GetCloseSignalByMa(shift, mode, ticket);

        int signal  = closeindicator.GetSignal(shift);
        if(signal != 0)
           {
             
            if(type == POSITION_TYPE_BUY && signal < 0)
               {
                ret = 1;
               }
            if(type == POSITION_TYPE_SELL && signal > 0)
               {
                ret = 1;
               }
           }
        /*
                if(ret == 0 )
                   {

                    double stop  = mystoploss * Point();
                    double take = mytakeprofit * Point();
                    double ask = Ask();
                    double bid = Bid();
                    double pos_price = cbexpert.OrderMachine.PositionOpenPrice(ticket);
                    if(type == POSITION_TYPE_BUY)
                       {
                        stop = NormalizeDouble(pos_price - stop, 3);
                        take = NormalizeDouble(pos_price + take, 3);
                        if(bid > take || bid < stop)
                            ret = 1;
                       }
                    else
                       {
                        stop = NormalizeDouble(pos_price + stop, 3);
                        take = NormalizeDouble(pos_price - take, 3);
                        if(ask > take || ask < stop)
                            ret = 1;
                       }
                   }
               }
               */
       }
    return ret;
   }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetCloseSignalByMa(int shift, int mode,  int ticket)
   {
    if(TrailingStop > 0)
        cbexpert.SetTrailingStop(TrailingStop);
// return 0;  ///// AUS!!!-----------------------------------------------------
    int ret = 0;
    double ma0 =  GetIndicatorBufferValue(maclose_handle, shift, 0);
    ENUM_POSITION_TYPE type = cbexpert.OrderMachine.PositionType(ticket);
    double win = cbexpert.OrderMachine.PositionProfit(ticket);
    double lastclose = iClose(Symbol(), PERIOD_CURRENT, shift);
    if(win > 0)
       {
        if(type == POSITION_TYPE_BUY)
           {
            if(lastclose < ma0)
                ret = 1;
           }
        else
           {
            if(lastclose > ma0)
                ret = 1;
           }
       }
//if (ret == 0 )
//{
//   ret = GetCloseSignalByMyVals(shift,mode, ticket);
//}

    return ret;
   }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
