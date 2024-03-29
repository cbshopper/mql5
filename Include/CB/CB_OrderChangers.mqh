//+------------------------------------------------------------------+
//|                                                      Commons.mqh |
//|                                                   Christof Blank |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Christof Blank"

#include <cb\CB_Utils.mqh>
#include <cb\CB_OrderMachine.mqh>
#include <cb\CB_Pips&Lots.mqh>
COrderMachine OrderMachine;


/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int               OrderSend(string   symbol,               // symbol
                            int      cmd,                 // operation
                            double   volume,              // volume
                            double   price,               // price
                            int      slippage,            // slippage
                            double   stoploss,            // stop loss
                            double   takeprofit,          // take profit
                            string   comment,        // comment
                            int      magic,             // magic number
                            datetime expiration)        // pending order expiration

  {
   return OrderMachine.OrderSend(symbol,cmd,volume,price,slippage,stoploss,takeprofit,comment,magic);

  }
*/
/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool              PositionModify(
   int        ticket,      // ticket
   double     stoploss,    // stop loss
   double     takeprofit)  // take profit
  {
   return OrderMachine.PositionModify(ticket,stoploss,takeprofit);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool              OrderModify(
   int        ticket,      // ticket
   double     price,       // price
   double     stoploss,    // stop loss
   double     takeprofit,  // take profit
   datetime   expiration,  // expiration
   color      arrow_color)   // color
  {
   return OrderMachine.OrderModify(ticket,price,stoploss,takeprofit,expiration);
  }
  //+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool              OrderModify(
   int        ticket,      // ticket
   double     price,       // price
   int     stoploss,    // stop loss
   int     takeprofit,  // take profit
   datetime   expiration,  // expiration
   color      arrow_color)   // color
  {
   return OrderMachine.OrderModify(ticket,price,stoploss,takeprofit,expiration);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool             PositionClose(
   int        ticket    // ticket

)
  {
   return OrderMachine.PositionClose(ticket);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PositionOpenPrice(int ticket)
  {
   return OrderMachine.PositionOpenPrice(ticket);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PositionTakeProfit(int ticket)
  {
   return OrderMachine.PositionTakeProfit(ticket);
  }
//+------------------------------------------------------------------+
double PositionStopLoss(int ticket)
  {
   return OrderMachine.PositionStopLoss(ticket);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double PositionOpenTime(int ticket)
  {
   return OrderMachine.PositionOpenTime(ticket);
  }
*/
//+------------------------------------------------------------------+


void Init()
{
   if (!OrderMachine.IsInitialized)
   {
     OrderMachine.Init();
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PositionsSetTPSL(int magic, int sl, int tp)
  {
   Init();
   OrderMachine.PositionModify( magic, sl, tp);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PositionsSetTPSL(int magic, double sl, double tp)
  {
   Init();
   OrderMachine.PositionModify( magic, sl, tp);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PositionsSetStop(int magic, int sl)
  {
   Init();
   OrderMachine.PositionsSetStop(Symbol(), magic, sl, 0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PositionsMoveToBreakeven(int magic, int minwin, int sl)
  {
   Init();
   OrderMachine.PositionsSetStop(Symbol(), magic, sl, minwin);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setPositionTPT(int ticket, int TakeProfitPips, bool remove)
  {
   double price = 0;
   Init();
   if(remove)
     {
      OrderMachine.PositionSetTPSL(ticket, 0, -1);
     }
   else
     {
      OrderMachine.PositionSetTPSL(ticket, 0, TakeProfitPips);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderSetTPSL(int ticket, int sl, int tp)
  {
   Init();
   return OrderMachine.OrderModify(ticket, 0, sl, tp, 0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderModify(int ticket, double price, double slprice, double tpprice, datetime expire)
  {
   Init();
   return OrderMachine.OrderModify(ticket, price, slprice, tpprice, expire);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool setPositionStop(int ticket, int sl)
  {
   Init();
   return OrderMachine.PositionSetStop(ticket, sl);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool setPositionTStop(int ticket, int trailingStop, int minWinTicks)
  {
   Init();
   return OrderMachine.PositionSetStop(ticket, trailingStop, minWinTicks);
  }
//+------------------------------------------------------------------+
datetime OrderOpenTime(int ticket)
  {
   Init();
   return OrderMachine.PositionOpenTime(ticket);
  }
//+------------------------------------------------------------------+
