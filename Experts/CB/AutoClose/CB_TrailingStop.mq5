//+------------------------------------------------------------------+
//|                                              CB_TrailingStop.mq5 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Christof Blank."

#property strict



double StartingAccountBalance = 0;
#define VERSION "000.099"
#property version  VERSION
/*****************************************
// 0.99   2021-02-04   Migration from mt4
/
*****************************************/
//extern string  Setting="Settings:";
#ifndef SCRIPT
input bool             AllSymbols = false;
#endif
input int              MagicNumber = 0;
input bool             CheckPositions = true;
input bool             CheckOrders = true;
input double           Risk = 1.0; // Risk in Percent, take it if >0
input double           CRV = 1.5;
input double           MaxAccountValue = 20000.0;
input bool             SetStoploss = true;
input bool             SetTrailingStop = false;
input bool             SetTakeProfit = false;
//input bool             UseATR = false;
//input ENUM_TIMEFRAMES  ATR_TimePeriod = PERIOD_CURRENT;
//input int              ATR_Period = 14;
//input int              ATR_StopMultiplier = 4;
//input int              ATR_ProfitMultiplier = 8;

input int              StopLoss = 50;
input int              TrailingStop = 50;
input int              TakeProfit = 100;
//input int              PendingOrdersTPTicks=100;
//input int              PendingOrdersStopTicks=50;
input int              MinProfitPips = 0;
input datetime          StartDateTime = 0;

int initial_StopLossTicks = 0;
int initial_TakeProfitTicks = 0;
double POINT = Point();
//---

//extern string              ForTesting="-- for testing porpuses only! --";
//extern bool                TESTMODE=false;
//extern double              testlots=1.0;
//extern int                 ma_period1=5;
//extern int                 ma_period2=15;

int ATRPtr = 0;
int stopLoss   = StopLoss;
int takeProfit = TakeProfit;
double lots = 0;
double risk = 0;
datetime startDateTime = StartDateTime;

#include <cb\CBUtils5.mqh>
#include <cb\CB_IndicatorHelper.mqh>
#include <cb\CB_OrderChangers.mqh>
#include <cb\CB_Pips&Lots.mqh>

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
   {
//---
    startDateTime = StartDateTime;
    if(StartDateTime == 0)
       {
        //  StartDateTime=TimeCurrent();
        MqlDateTime start;
        startDateTime = TimeCurrent(start);
        start.hour = 0;
        start.min = 0;
        start.sec = 0;
        startDateTime = StructToTime(start);
       }
#ifndef SCRIPT
    Comment(__FILE__, " V", VERSION, " : StartTime is ", TimeToString(startDateTime, TIME_DATE | TIME_MINUTES | TIME_SECONDS));
#endif
    initial_StopLossTicks = stopLoss;
    initial_TakeProfitTicks = takeProfit;
//if(UseATR)
//   {
//      ATRPtr = iATR(NULL, ATR_TimePeriod, ATR_Period);
//   }
    POINT =  Point(); // TickValue(); //PipValue(NULL);
//--- create timer
    EventSetTimer(1);
//---
    return(INIT_SUCCEEDED);
   }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
   {
//--- destroy timer
    EventKillTimer();
   }

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
   {
//---
    DoMyJob(CheckPositions, CheckOrders, StartDateTime);
   }

datetime lastTime = 0;
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
   {
   }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DoMyJob(bool checkPositions, bool checkOrders, datetime startDT)
   {
//---
// open Order --------------------------------------------------------------------
    if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
       {
        Comment("Trade not allowed");
        Print(__FUNCTION__, ": " + Symbol() + " Trading not allowed");
        return;
       }
    string curSymbol = Symbol();
    if(AllSymbols)
        curSymbol = "";
//---  ORDERS---------------------------------------------------------------------
    if(checkOrders)
       {
        int ticket = findNewOrder(curSymbol, MagicNumber, startDT, lots);
        while(ticket > 0)
           {
            if(OrderSelect(ticket))
               {
                CalculateSLTP(ticket, false);
                string sym = OrderGetString(ORDER_SYMBOL);
                Print(__FUNCTION__, ": " + sym + " Order #=", ticket, " stopLoss=", stopLoss, " takeProfit=", takeProfit, " Lots=", lots, " Risk=", risk);
                if(SetStoploss)
                   {
                    OrderSetTPSL(ticket, stopLoss, 0);
                   }
                if(SetTakeProfit)
                   {
                    OrderSetTPSL(ticket, 0, takeProfit);
                   }
                ticket = findNewOrder(Symbol(), MagicNumber, startDT, lots);
               }
           }
       }
//--- POSITIONS ------------------------------------------------------------------
    if(checkPositions)
       {
        int ticket = findNewPosition(curSymbol, MagicNumber, startDT, lots);
        while(ticket > 0)
           {
            if(PositionSelectByTicket(ticket))
               {
                CalculateSLTP(ticket, true);
                string sym = PositionGetString(POSITION_SYMBOL);
                Print(__FUNCTION__, ": " + sym + " Position #=", ticket, " stopLoss=", stopLoss, " takeProfit=", takeProfit, " Lots=", lots, " Risk=", risk);
                if(OrderOpenTime(ticket) > startDateTime || startDateTime == 0)
                   {
                    if(SetStoploss)
                       {
                        if(MinProfitPips == 0)
                           {
                            PositionsSetTPSL(ticket, stopLoss, 0);
                           }
                       }
                    if(SetTrailingStop)
                       {
                        setPositionTStop(ticket, TrailingStop, MinProfitPips);
                       }
                    if(SetTakeProfit)
                       {
                        PositionsSetTPSL(ticket, 0, takeProfit);
                        // setPositionTPT(ticket, takeProfit, false);
                       }
                   }
                ticket = findNewPosition(Symbol(), MagicNumber, startDT, lots);
               }
           }
       }
   }

//+------------------------------------------------------------------+
int findNewOrder(string symbol, int Magic, datetime Starttime, double &lots)
   {
    int itotal = OrdersTotal();
    double price = 0;
    ulong ticket;
    for(int cnt = itotal - 1; cnt >= 0; cnt--)
       {
        if((ticket = OrderGetTicket(cnt)) > 0)
           {
            long    magic = OrderGetInteger(ORDER_MAGIC);
            string sym =  OrderGetString(ORDER_SYMBOL);
            long open = OrderGetInteger(ORDER_TIME_SETUP);
            double tp = OrderGetDouble(ORDER_TP);
            double sl = OrderGetDouble(ORDER_SL);
            long type = OrderGetInteger(ORDER_TYPE);               //OrderType();
            if((sym == symbol || symbol == "") && magic == Magic)
               {
                if(type > ORDER_TYPE_SELL)
                   {
                    if(open > Starttime || Starttime == 0)
                       {
                        if((sl == 0 && tp == 0)  && (SetStoploss || SetTakeProfit))
                           {
                            lots = OrderGetDouble(ORDER_VOLUME_CURRENT);
                            return ((int)ticket);
                           }
                       }
                   }
               }
           }
       }
    return(0);
   }
//+------------------------------------------------------------------+
int findNewPosition(string symbol, int Magic, datetime Starttime, double &lots)
   {
    int itotal = PositionsTotal();
    double price = 0;
    ulong ticket;
    for(int cnt = itotal - 1; cnt >= 0; cnt--)
       {
        if((ticket = PositionGetTicket(cnt)) > 0)
           {
            long    magic = PositionGetInteger(POSITION_MAGIC);
            string sym =  PositionGetString(POSITION_SYMBOL);
            long open = PositionGetInteger(POSITION_TIME);
            double tp = PositionGetDouble(POSITION_TP);
            double sl = PositionGetDouble(POSITION_SL);
            long type = PositionGetInteger(POSITION_TYPE);               //PositionType();
            if((sym == symbol || symbol == "") && magic == Magic)
               {
                if(open > Starttime || Starttime == 0)
                   {
                    if((sl == 0 && tp == 0)  && (SetStoploss || SetTakeProfit))
                       {
                        lots = PositionGetDouble(POSITION_VOLUME);
                        return ((int)ticket);
                       }
                   }
               }
           }
       }
    return(0);
   }
//+------------------------------------------------------------------+
bool CalculateSLTP(int ticket, bool IsPosition)
   {
    bool ret = false;
    string symbol="";
// calculate Stopploss -----------------------------------------------------------
//if(UseATR)
//   {
//      double ATR =     GetIndicatorValue(ATRPtr, 0); //iATR(NULL,ATR_TimePeriod,ATR_Period,0);
//      ATR *= ATR_StopMultiplier;
//      if(ATR <= (MarketInfo(Symbol(), MODE_STOPLEVEL) + MarketInfo(Symbol(), MODE_SPREAD))*POINT)
//         ATR = (MarketInfo(Symbol(), MODE_STOPLEVEL) + MarketInfo(Symbol(), MODE_SPREAD)) * POINT;
//      if((ATR / POINT) < initial_StopLossTicks)
//         ATR = initial_StopLossTicks * POINT;
//      stopLoss = int (ATR / POINT);
//      ret=true;
//   }
//else
    if(Risk > 0)
       {
        lots = 0;
        if(IsPosition)
           {
            if(PositionSelectByTicket(ticket))
               {
                lots = PositionGetDouble(POSITION_VOLUME);
                symbol=PositionGetString(POSITION_SYMBOL);
               }
           }
        else
           {
            if(OrderSelect(ticket))
               {
                lots = OrderGetDouble(ORDER_VOLUME_CURRENT);
                symbol=OrderGetString(ORDER_SYMBOL);
               }
           }
        if(lots > 0)
           {
            double money = AccountInfoDouble(ACCOUNT_BALANCE);
            if(money > MaxAccountValue && MaxAccountValue > 0)
                money = MaxAccountValue;
            risk = money * Risk / 100;
            stopLoss = calculateStopLossPoints(symbol,risk, lots);
            ret = true;
           }
       }
    else
       {
        stopLoss = StopLoss;
        takeProfit = TakeProfit;
        ret = true;
       }
    if(ret)
       {
        stopLoss = (int) CheckSL(symbol,stopLoss);
        if(CRV > 0)
            takeProfit = (int)(stopLoss * CRV + MarketInfo(Symbol(), MODE_SPREAD));
        takeProfit = (int) CheckSL(symbol,takeProfit);
       }
    return ret;
   }
//+------------------------------------------------------------------+
