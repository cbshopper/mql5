//+------------------------------------------------------------------+
//|                                                     CBUtils5.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <cb\CB_MT4.mqh>
/*
enum MQL4_ORDER_MODES
  {
   OP_BUY= 0,        // Buy operation
   OP_SELL=1,        // Sell operation
   OP_BUYLIMIT=2,    // Buy limit pending order
   OP_SELLLIMIT=3,   // Sell limit pending order
   OP_BUYSTOP=4,     // Buy stop pending order
   OP_SELLSTOP=5     // Sell stop pending order

  };
*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetIndicatorValue(int handle, int index)
  {
   double ret = GetIndicatorBufferValue(handle,index,0);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetIndicatorBufferValue(int handle, int index,int bufferno)
  {
   double ret =0;
   double vals[1];
   int errno=0;
   if(CopyBuffer(handle,bufferno,index,1,vals) > 0)
     {
      ret = vals[0];
     }
     else
     {
         errno = GetLastError();
     }
   return ret;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ObjectFind(string name)
  {
   return ObjectFind(0,name);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ObjectDelete(string name)
  {
   return ObjectDelete(0,name);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  ObjectCreate(string name,ENUM_OBJECT obj,int subwindow, datetime time, double value)
  {
   return ObjectCreate(0,name,obj,subwindow,time,value);
  }
  
bool   OrderSelect(int val , int select_type, int trademode)
{
   if (select_type == SELECT_BY_TICKET)
   {
      if (trademode ==MODE_TRADES)
      {
         return PositionSelectByTicket(val);
      }
      else
       {
         return HistoryDealSelect(val);
       }
   }
   if (select_type == SELECT_BY_POS)
   {
       if (trademode ==MODE_TRADES)
      {
         int ticket = OrderGetTicket(val);
         if (ticket > -1 )return OrderSelect(ticket);
      }
      else
       {
         int ticket = HistoryDealGetTicket(val);
         if (ticket > -1 ) return HistoryDealSelect(ticket);
       }
   }
   return false;
}

string OrderSymbol()
{
   return OrderGetString(ORDER_SYMBOL);
}
int OrderType()
{
  return OrderGetInteger(ORDER_TYPE);
}
void OrderPrint()
{
   Print(__FUNCTION__, OrderGetString(ORDER_SYMBOL), ":",OrderGetInteger(ORDER_MAGIC));
}
/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void convertOrderType(int mode, ENUM_ORDER_TYPE & type,   ENUM_TRADE_REQUEST_ACTIONS& action)
  {

   switch(mode)
     {
      case OP_BUY:
         type=ORDER_TYPE_BUY;
         action = TRADE_ACTION_DEAL;
         break;
      case OP_SELL:
         type=ORDER_TYPE_BUY;
         action = TRADE_ACTION_DEAL;
         break;
      case OP_BUYLIMIT:
         type=ORDER_TYPE_BUY_LIMIT;
         action = TRADE_ACTION_PENDING;
         break;
      case OP_SELLLIMIT:
         type=ORDER_TYPE_SELL_LIMIT;
         action = TRADE_ACTION_PENDING;
         break;
      case OP_BUYSTOP:
         type=ORDER_TYPE_BUY_STOP;
         action = TRADE_ACTION_PENDING;
         break;
      case OP_SELLSTOP:
         type=ORDER_TYPE_SELL_STOP;
         action = TRADE_ACTION_PENDING;
         break;

     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  OrderSend(string   symbol,               // symbol
               int      cmd,                 // operation
               double   volume,              // volume
               double   price,               // price
               int      slippage,            // slippage
               double   stoploss,            // stop loss
               double   takeprofit,          // take profit
               string   comment=NULL,        // comment
               int      magic=0,             // magic number
               datetime expiration=0,        // pending order expiration
               color    arrow_color=clrNONE)  // color )
  {
//--- prepare a request
   MqlTradeRequest request= {0};
   ENUM_ORDER_TYPE ordertype;
   ENUM_TRADE_REQUEST_ACTIONS orderaction;
   convertOrderType(cmd,ordertype,orderaction);

   request.action=orderaction;         // setting a pending order
   request.magic=magic;                  // ORDER_MAGIC
   request.symbol=symbol;                      // symbol
   request.volume=volume;                          // volume in 0.1 lots
   request.sl=stoploss;                                // Stop Loss is not specified
   request.tp=takeprofit;                                // Take Profit is not specified
//--- form the order type
   request.type=ordertype;                // order type
//--- form the price for the pending order
   request.price=price;  // open price
//--- send a trade request
   MqlTradeResult result= {0};
   OrderSend(request,result);
//--- write the server reply to log
   Print(__FUNCTION__,":",result.comment);
   if(result.retcode==10016)
      Print(result.bid,result.ask,result.price);
//--- return code of the trade server reply
   return result.retcode;
  } 
//+------------------------------------------------------------------+

bool  OrderModify( 
   int        ticket,      // ticket 
   double     price,       // price 
   double     stoploss,    // stop loss 
   double     takeprofit,  // take profit 
   datetime   expiration,  // expiration 
   color      arrow_color  // color 
   )
   {
     if ( OrderSelect(ticket) )
     {  
       MqlTradeRequest request= {0};
       request.magic = ticket;
   request.symbol=symbol;                      // symbol
   request.volume=volume;                          // volume in 0.1 lots
   request.sl=stoploss;                                // Stop Loss is not specified
   request.tp=takeprofit;                                // Take Profit is not specified
//--- form the order type
   request.type=ordertype;                // order type
//--- form the price for the pending order
   request.price=price;  // open price
//--- send a trade request
   MqlTradeResult result= {0};
   OrderSend(request,result);
//--- write the server reply to log
   Print(__FUNCTION__,":",result.comment);
   if(result.retcode==10016)
      Print(result.bid,result.ask,result.price);
//--- return code of the trade server reply
   return result.retcode;
     }
     
   }
   */
   
  