//+------------------------------------------------------------------+
//|                                                      Commons.mqh |
//|                                                   Christof Blank |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Christof Blank"
#property link      ""
//#property strict
//#include <stdlib.mqh>
//#include <cb\debug_inc.mqh>
// #include <WinUser32.mqh>
#include <cb\CB_Utils.mqh>
#include <cb\CB_OrderFunctions.mqh>
#include <cb\CB_Pips&Lots.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrdersSetStop(string symbol,int magic,int StoppLoss, int minwin)
  {
   int total=OrdersTotal();
   int ticket=0;
   int cnt=0;
   for(cnt=0; cnt<total; cnt++)
     {
      if((ticket=OrderGetTicket(cnt))>0)
        {
         string o_symbol  =   OrderGetString(ORDER_SYMBOL);
         string o_magic   =   OrderGetInteger(ORDER_MAGIC);
         ENUM_ORDER_TYPE o_type          =EnumToString(ENUM_ORDER_TYPE(OrderGetInteger(ORDER_TYPE)));
         if(o_type<=ORDER_TYPE_SELL && // check for opened position
            (o_symbol==symbol || symbol=="") && // check for symbol
            o_magic==magic) // check for magic
           {
            OrderMachine.OrderSetStop(ticket,StoppLoss,minwin);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrdersSetStop(int magic,int sl)
  {
   OrdersSetStop(Symbol(),magic,sl,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MOVETOBREAKEVEN(int magic, int minwin, int sl)
  {
   OrdersSetStop(Symbol(),magic,sl,minwin);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrdersSetStopBAK(string symbol,int magic,int StoppLoss)
  {
   int cnt;
   bool ret=true;
   bool ok=false;
   int error=0;
   double buyStopPrice=0;
   double sellStopPrice=0;
   double win=0;
   int ticket;



   int total=OrdersTotal();
   for(cnt=0; cnt<total; cnt++)
     {
      if((ticket=OrderGetTicket(cnt))>0)
        {
         string o_symbol  =   OrderGetString(ORDER_SYMBOL);
         string o_magic   =   OrderGetInteger(ORDER_MAGIC);
         double o_price   =   OrderGetDouble(ORDER_PRICE_OPEN);
         ENUM_ORDER_TYPE o_type          =EnumToString(ENUM_ORDER_TYPE(OrderGetInteger(ORDER_TYPE)));
         double orderTakeProfit = OrderGetDouble(ORDER_TP);
         double orderStopLoss = OrderGetDouble(ORDER_SL);

         if(o_type<=ORDER_TYPE_SELL && // check for opened position
            (o_symbol==symbol || symbol=="") && // check for symbol
            o_magic==magic) // check for magic
           {
            double pp=Point(); //MarketInfo(OrderSymbol(),MODE_POINT);
            StoppLoss=CheckStopLossPips(o_symbol,StoppLoss);
            sellStopPrice=SymbolInfoDouble(o_symbol,SYMBOL_ASK)+pp*StoppLoss;
            buyStopPrice=SymbolInfoDouble(o_symbol,SYMBOL_BID)-pp*StoppLoss;
            sellStopPrice = CheckPriceVal(sellStopPrice);
            buyStopPrice = CheckPriceVal(buyStopPrice);

            if(StoppLoss>0)
              {
               if(o_type==ORDER_TYPE_BUY) // long position is opened
                 {
                  if(orderStopLoss==0)
                    {
                     Print(__FUNCTION__," TrailingStop="+(string)StoppLoss);
                     ok=OrderModify(ticket,o_price,NormalizeDouble(buyStopPrice,4),orderTakeProfit,0,Green);
                     if(!ok)
                       {
                        error=GetLastError();
                        Print(__FUNCTION__," Order #"+(string)ticket+" Error = ",ErrorDescription(error));
                        ret=false;
                       }
                    }
                 }
               if(o_type==ORDER_TYPE_SELL) // short position is opened
                 {
                  if(orderStopLoss==0)
                    {
                     Print(__FUNCTION__," TrailingStop="+(string)StoppLoss);
                     ok=OrderModify(ticket,o_price,NormalizeDouble(sellStopPrice,4),orderTakeProfit,0,Red);
                     if(!ok)
                       {
                        error=GetLastError();
                        Print(__FUNCTION__," Order #"+(string)ticket+" Error = ",ErrorDescription(error));
                        ret=false;
                       }
                    }
                 }
              }
           }
        }
     }

   return ret;
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setOrderTPT(int ticket,int TakeProfitPips,bool remove)
  {
   double price=0;

   if(remove)
     {
      OrderMachine.OrderSetSLTP(ticket,0,-1);
     }
   else
     {

      OrderMachine.OrderSetSLTP(ticket,0,TakeProfitPips);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool pendingOrderSetTPSL(int ticket, int StoppLoss, int TakeProfit)
  {
   return OrderMachine.PendingOrderSetSLTP(ticket,StoppLoss,TakeProfit);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool setOrderStop(int ticket, int StoppLoss)
  {

   return OrderMachine.OrderSetStop(ticket,StoppLoss);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool setOrderTStop(int ticket, int TrailingStop,int MinWinTicks)
  {

   return OrderMachine.OrderSetStop(ticket,TrailingStop,MinWinTicks);

  }
//+------------------------------------------------------------------+
