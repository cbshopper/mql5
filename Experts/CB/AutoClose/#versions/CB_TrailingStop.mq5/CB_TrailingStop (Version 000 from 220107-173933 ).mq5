//+------------------------------------------------------------------+
//|                                              CB_TrailingStop.mq5 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Christof Blank."

#property strict



double StartingAccountBalance=0;
#define VERSION "000.99"
#property version  VERSION
/*****************************************
// 0.99   2021-02-04   Migration from mt4
/
*****************************************/
//extern string  Setting="Settings:";
extern int              MagicNumber=0;
extern bool             OnlyPendingOrder=false;
extern double           Risk=1.0; // Risk in Percent, take it if >0
extern double           CRV=1.5;
extern double           MaxAccountValue=10000.0;
extern bool             SetStoploss=true;
extern bool             SetTrailingStop=false;
extern bool             SetTakeProfit=true;
extern bool             UseATR=true;
extern ENUM_TIMEFRAMES  ATR_TimePeriod=PERIOD_M15;
extern int              ATR_Period=14;
extern int              ATR_StopMultiplier=4;
extern int              ATR_ProfitMultiplier=8;

extern int              StopLoss=50;
extern int              TrailingStop=50;
extern int              TakeProfit=100;
//extern int              PendingOrdersTPTicks=100;
//extern int              PendingOrdersStopTicks=50;
extern int              MinProfitPips=0;
extern datetime          StartDateTime= 0;

int initial_StopLossTicks=0;
int initial_TakeProfitTicks=0;
double POINT=Point();

extern string              ForTesting="-- for testing porpuses only! --";
extern bool                TESTMODE=false;
extern double              testlots=1.0;
extern int                 ma_period1=5;
extern int                 ma_period2=15;

int ATRPtr=0;

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
   if(StartDateTime==0)
     {
    //  StartDateTime=TimeCurrent();

      MqlDateTime start;
      StartDateTime=TimeCurrent(start);
      start.hour = 0;
      start.min=0;
      start.sec=0;
      StartDateTime = StructToTime(start);
     }
#ifndef SCRIPT
   Comment(__FILE__," V",VERSION," : StartTime is ", TimeToString(StartDateTime,TIME_DATE| TIME_MINUTES|TIME_SECONDS));
#endif
   initial_StopLossTicks=StopLoss;
   initial_TakeProfitTicks=TakeProfit;
   if (UseATR)
   {
     ATRPtr= iATR(NULL,ATR_TimePeriod,ATR_Period);
   }

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
   DoMyJob();
  }

datetime lastTime=0;
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DoMyJob()
  {


//---
   double lots=0;
   double risk=0;

// open Order --------------------------------------------------------------------
   if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
   {
      Comment("Trade not allowed");
               Print(__FUNCTION__, ": " + Symbol() + " Trading not allowed");
               return;
   }
   int ticket = findNewOrder(Symbol(),MagicNumber,StartDateTime,lots);
   while(ticket > 0)
     {
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
        {
        
         // calculate Stopploss
         if(Risk > 0)
           {
            double money=AccountInfoDouble(ACCOUNT_BALANCE);
            if(money>MaxAccountValue && MaxAccountValue>0)
               money = MaxAccountValue;
            risk=money*Risk/100;
            StopLoss = calculateStopLossPoints(risk,lots);

           }
         else
           {
            if(UseATR)
              {
               double ATR=     GetIndicatorValue(ATRPtr,0);  //iATR(NULL,ATR_TimePeriod,ATR_Period,0);
               ATR*=ATR_StopMultiplier;
               if(ATR<=(MarketInfo(Symbol(),MODE_STOPLEVEL)+MarketInfo(Symbol(),MODE_SPREAD))*POINT)
                  ATR= (MarketInfo(Symbol(),MODE_STOPLEVEL)+MarketInfo(Symbol(),MODE_SPREAD))*POINT;
               if((ATR/POINT) < initial_StopLossTicks)
                  ATR= initial_StopLossTicks*POINT;
               StopLoss=ATR/POINT;
              }
           }

         // calculate TakeProfit
         if(CRV > 0)
            TakeProfit=StopLoss*CRV + MarketInfo(Symbol(),MODE_SPREAD);

         StopLoss=CheckSL(StopLoss);
         TakeProfit=CheckSL(TakeProfit);

         //  Print(__FUNCTION__, ": " + Symbol() + " Ticket=", ticket, " StopLoss=",StopLoss," Order #",ticket, " Lots=",lots," Risk=",risk);

         Print(__FUNCTION__, ": " + Symbol() + " Order #=",ticket, " StopLoss=",StopLoss," TakeProfit=",TakeProfit," Lots=",lots," Risk=",risk);


         // Pending Order ------------------------------------------------
         if(OrderType()>OP_SELL)
           {
            if(SetStoploss)
              {
               //pendingOrderSetTPSL(ticket,StopLoss,0);
               OrderModify(ticket,0,StoppLoss,0,0);
              }
            if(SetTakeProfit)
              {
               // pendingOrderSetTPSL(ticket,0,TakeProfit);
                OrderModify(ticket,0,0,TakeProfit,0);
              }
           }
         else
           {
            if(OrderOpenTime(ticket) > StartDateTime || StartDateTime == 0)
              {
               if(SetStoploss)
                 {
                  if(MinProfitPips==0)
                    {
                     //        print("OrderSetStop");
                     //   OrderSetStopT(Symbol(),MagicNumber,StopLoss,StartDateTime);
                     setOrderStop(ticket,StopLoss);
                    }
                 }
               if(SetTrailingStop)
                 {
                  //     print("OrderSetTStop");
                  // OrderSetTStopT(Symbol(),MagicNumber,TrailingStop,MinProfitPips,StartDateTime);
                  setOrderTStop(ticket,TrailingStop,MinProfitPips);
                 }
               if(SetTakeProfit)
                 {
                  //OrderSetTPT(Symbol(),MagicNumber,TakeProfit,false,StartDateTime);
                  setOrderTPT(ticket,TakeProfit,false);
                 }
              }
           }
         ticket = findNewOrder(Symbol(),MagicNumber,StartDateTime,lots);
        }
     }
  }

//+------------------------------------------------------------------+
int findNewOrder(string symbol,int Magic, datetime Starttime,double &lots)
  {
   int itotal=OrdersTotal();
   double price=0;
   int ticket;
   
   
   for(int cnt=itotal-1; cnt>=0; cnt--)
     {
      if((ticket=OrderGetTicket(cnt))>0) 

        {
         int    magic =OrderGetInteger(ORDER_MAGIC); 
         string sym =  OrderGetString(ORDER_SYMBOL);
         datetime open = OrderGetInteger(ORDER_TIME_SETUP);
         double tp =OrderGetDouble(ORDER_TP);
         double sl = OrderGetDouble(ORDER_SL);
         int type = OrderGetInteger(ORDER_TYPE);               //OrderType();


         if((sym==symbol || symbol=="") && magic==Magic)
           {
            if(type > ORDER_TYPE_SELL || !OnlyPendingOrder)
              {
               if(open > Starttime || Starttime == 0)
                 {
                  if((sl == 0 && tp ==0)  && (SetStoploss || SetTakeProfit))
                    {
                     lots=OrderGetDouble(ORDER_VOLUME_CURRENT);
                     return (ticket);
                    }
                 }
              }
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
