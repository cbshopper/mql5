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

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PositionsSetStop(string symbol,int magic,int StoppLoss, int minwin)
  {
   int total=PositionsTotal();
   int ticket=0;
   int cnt=0;
   for(cnt=0; cnt<total; cnt++)
     {
      if((ticket=PositionGetTicket(cnt))>0)
        {
         string o_symbol  =   PositionGetString(POSITION_SYMBOL);
         string o_magic   =   PositionGetInteger(POSITION_MAGIC);
         if((o_symbol==symbol || symbol=="") && // check for symbol
            o_magic==magic) // check for magic
           {
            OrderMachine.PositionSetStop(ticket,StoppLoss,minwin);
           }
        }
     }
  }
  
  void PositionsModify(string symbol,int magic, ENUM_POSITION_TYPE type, double StoppLoss, double TakeProfit)
  {
   int total=PositionsTotal();
   int ticket=0;
   int cnt=0;
   Print(__FUNCTION__," total=",total);
   for(cnt=0; cnt<total; cnt++)
     {
      if((ticket=PositionGetTicket(cnt))>0)
        {
         string o_symbol  =   PositionGetString(POSITION_SYMBOL);
         string o_magic   =   PositionGetInteger(POSITION_MAGIC);
         string o_type    =   PositionGetInteger(POSITION_TYPE);
         if((o_symbol==symbol || symbol=="") && // check for symbol
            o_type == type &&
            o_magic==magic) // check for magic
           {
            OrderMachine.PositionModify(ticket,StoppLoss,TakeProfit);
           }
        }
     }
  }
  
  
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PositionsSetStop(int magic,int sl)
  {
   PositionsSetStop(Symbol(),magic,sl,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PositionsMoveToBreakeven(int magic, int minwin, int sl)
  {
   PositionsSetStop(Symbol(),magic,sl,minwin);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setPositionTPT(int ticket,int TakeProfitPips,bool remove)
  {
   double price=0;

   if(remove)
     {
      OrderMachine.PositionSetTPSL(ticket,0,-1);
     }
   else
     {

      OrderMachine.PositionSetTPSL(ticket,0,TakeProfitPips);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderSetTPSL(int ticket, int StoppLoss, int TakeProfit)
  {
   return OrderMachine.OrderModify(ticket,0,StoppLoss,TakeProfit,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderModify(int ticket, double price, double slprice,double tpprice, datetime expire)
  {
   return OrderMachine.OrderModify(ticket,price,slprice,tpprice,expire);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrdersModify(string symbol,int magic,ENUM_ORDER_TYPE type,double price,int sl,int tp,datetime new_expiration)
  {
   int total=OrdersTotal();
   int ticket=0;
   int cnt=0;
  Print(__FUNCTION__," total=",total);
   for(cnt=0; cnt<total; cnt++)
     {
      if((ticket=OrderGetTicket(cnt))>0)
        {
         string o_symbol  =   OrderGetString(ORDER_SYMBOL);
         string o_magic   =   OrderGetInteger(ORDER_MAGIC);
         string o_type    =   OrderGetInteger(ORDER_TYPE);
         if((o_symbol==symbol || symbol=="") && // check for symbol
            o_type == type &&
            o_magic==magic) // check for magic
           {
            OrderMachine.OrderModify(ticket,price,sl,tp,new_expiration);
           }
        }
     }
  }
  //+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrdersModify(string symbol,int magic,ENUM_ORDER_TYPE type,double price,double slprice,double tprice,datetime new_expiration)
  {
   int total=OrdersTotal();
   int ticket=0;
   int cnt=0;
   Print(__FUNCTION__," total=",total);
   for(cnt=0; cnt<total; cnt++)
     {
      if((ticket=OrderGetTicket(cnt))>0)
        {
         string o_symbol  =   OrderGetString(ORDER_SYMBOL);
         string o_magic   =   OrderGetInteger(ORDER_MAGIC);
         string o_type    =   OrderGetInteger(ORDER_TYPE);
         if((o_symbol==symbol || symbol=="") && // check for symbol
            o_type == type &&
            o_magic==magic) // check for magic
           {
            OrderMachine.OrderModify(ticket,price,slprice,tprice,new_expiration);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool setPositionStop(int ticket, int StoppLoss)
  {

   return OrderMachine.PositionSetStop(ticket,StoppLoss);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool setPositionTStop(int ticket, int TrailingStop,int MinWinTicks)
  {

   return OrderMachine.PositionSetStop(ticket,TrailingStop,MinWinTicks);

  }
//+------------------------------------------------------------------+
