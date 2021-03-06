//+------------------------------------------------------------------+
//|                                              CB_OrderManager.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//#include <CB_Commons.mqh>
#include <cb\CB_OrderFunctions.mqh>
#define ORDER_MANAGER_INCLUDED
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#ifndef  ORDERINFOTYPE_DEFINED
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct OrderInfoType
  {
   int               ticket;
   double            lots;
   double            profit;
   double            price;
   datetime          opentime;
   double            max_profit;
   //   double            close_profit;
   bool              flag;
   int               type;
  };
#endif

OrderInfoType BuyOrders[];
OrderInfoType SellOrders[];

// Number of orders
int BuyOrderCount=0;
int SellOrderCount=0;
//int virt_buys=0;
//int virt_sells=0;

int                slippage=5;

double current_buy_profit=0,current_sell_profit=0;
double last_buy_profit=0,last_sell_profit=0;
double total_buy_lots=0, total_sell_lots=0;
double buy_max_profit=0, buy_close_profit=0;
double sell_max_profit=0,sell_close_profit=0;
double max_profit=0,close_profit=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SizeBuyArray(int size)
  {
   ArrayResize(BuyOrders,size);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SizeSellArray(int size)
  {
   ArrayResize(SellOrders,size);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getOrderFromList(int ticket,OrderInfoType &list[])
  {
   int ret=0;
   int Len=  ArraySize(list);
   bool found=false;
   for(ret=0; ret<Len; ret++)
     {
      if(list[ret].ticket==ticket)
        {
         found=true;
         break;
        }
     }
   if(!found)
     {
      ArrayResize(list,Len+1);
      ret=ArraySize(list)-1;
      list[ret].max_profit=0;
     }
//   print(__FUNCTION__," : ret=",ret);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int findTicketIndex(int ticket,OrderInfoType &list[])
  {
   int ret=-1;
   int Len=  ArraySize(list);
   bool found=false;
   for(int i =0; i<Len; i++)
     {
      if(list[i].ticket==ticket)
        {
         ret=i;
         break;
        }
     }
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderListSetFlag(OrderInfoType &list[],bool value)
  {
   for(int i=0; i<ArraySize(list); i++)
     {
      list[i].flag=value;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderListRemove(OrderInfoType &list[],bool value)
  {
   int index=0;
   int Len=ArraySize(list);

   while(index<Len)
     {
      if(list[index].flag==value)
        {
         for(int i=index; i<Len-1; i++)
           {
            list[i]=list[i+1];
           }
         ArrayResize(list,Len-1,0);
         index=0;
         Len=ArraySize(list);
        }
      else
        {
         index++;
        }
     }
//    print(__FUNCTION__,": ArraySize=",Len);
   return Len;
  }
// ------------------------------------------------------------------------------------------------
// INIT VARS
// ------------------------------------------------------------------------------------------------
void InitVars()
  {
// Reset number of buy/sell orders
   BuyOrderCount=0;
   SellOrderCount=0;
// Reset arrays
   SizeBuyArray(BuyOrderCount);
   SizeSellArray(SellOrderCount);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetInfo(OrderInfoType &entry)
  {
   entry.ticket=OrderTicket();
   entry.lots=OrderLots();
   entry.profit=OrderProfit()+OrderCommission()+OrderSwap();
   entry.price = OrderOpenPrice();
   entry.opentime=OrderOpenTime();
   entry.type=OrderType();
   entry.flag=false;
   if(entry.profit>0)
     {
      if(entry.max_profit<entry.profit)
         entry.max_profit=entry.profit;
     }
//   print("!!!", __FUNCTION__,StringFormat(": ticket=%d, lots=%f, profit=%f, price=%f, opentime = %s",entry.ticket,entry.lots,entry.profit,entry.price,TimeToStr(entry.opentime)));
  }

// ------------------------------------------------------------------------------------------------
// UPDATE VARS
// ------------------------------------------------------------------------------------------------
void UpdateOrderlist(int magic)
  {
   OrderInfoType entry;
   int aux_buys=0,aux_sells=0;
   double aux_total_buy_profit=0,aux_total_sell_profit=0;
   double aux_total_buy_lots=0,aux_total_sell_lots=0;
//   InitVars();
   OrderListSetFlag(BuyOrders,true);
   OrderListSetFlag(SellOrders,true);
// We are going to introduce data from opened orders in arrays
   int cnt=OrdersTotal();
   for(int i=0; i<cnt; i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==true)
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
           {

            //     print(__FUNCTION__,"=============>>  Ticket=",OrderTicket());
            if(OrderType()==OP_BUY)
              {

               // SizeBuyArray(aux_buys+1);
               aux_buys=getOrderFromList(OrderTicket(),BuyOrders);
               SetInfo(BuyOrders[aux_buys]);
               aux_total_buy_profit=aux_total_buy_profit+BuyOrders[aux_buys].profit;
               aux_total_buy_lots=aux_total_buy_lots+OrderLots();
               entry=BuyOrders[aux_buys];
               //          print("!!!", __FUNCTION__,StringFormat(": BUYORDER %d: ticket=%d, lots=%f, profit=%f, price=%f, opentime = %s",aux_buys,entry.ticket,entry.lots,entry.profit,entry.price,TimeToStr(entry.opentime)));
               //   aux_buys++;
              }
            if(OrderType()==OP_SELL)
              {
               //  SizeSellArray(aux_sells+1);
               aux_sells=getOrderFromList(OrderTicket(),SellOrders);
               SetInfo(SellOrders[aux_sells]);
               aux_total_sell_profit=aux_total_sell_profit+SellOrders[aux_sells].profit;
               aux_total_sell_lots=aux_total_sell_lots+OrderLots();
               entry=SellOrders[aux_sells];
               //         print("!!!", __FUNCTION__,StringFormat(": SELLORDER %d: ticket=%d, lots=%f, profit=%f, price=%f, opentime = %s",aux_sells,entry.ticket,entry.lots,entry.profit,entry.price,TimeToStr(entry.opentime)));
               //   aux_sells++;
              }
           }
        }
     }
   OrderListRemove(BuyOrders,true);
   OrderListRemove(SellOrders,true);
//  if (aux_sells >0) print("!!!!",__FUNCTION__,": SellOrders[0].lots=" + SellOrders[0].lots);
// Update global vars
   BuyOrderCount=ArraySize(BuyOrders); //aux_buys;
   SellOrderCount=ArraySize(SellOrders); // aux_sells;
   last_buy_profit=current_buy_profit;
   last_sell_profit=current_sell_profit;
   current_buy_profit=aux_total_buy_profit;
   current_sell_profit=aux_total_sell_profit;
   total_buy_lots=aux_total_buy_lots;
   total_sell_lots=aux_total_sell_lots;
   /*
     for ( i = 0; i < BuyOrderCount; i++)
     {
       print(__FUNCTION__,": BuyOrders: i=",i," Ticket=#",BuyOrders[i].ticket);

     }
        for ( i = 0; i < SellOrderCount; i++)
     {
       print(__FUNCTION__,": SellOrders: i=",i," Ticket=#",SellOrders[i].ticket);

     }
    */
  }
// ------------------------------------------------------------------------------------------------
// SORT BY LOTS
// ------------------------------------------------------------------------------------------------
void SortByLots()
  {
   int i,j;
   OrderInfoType tmp;

// We are going to sort orders by volume
// m[0] smallest volume m[size-1] largest volume

// BUY ORDERS
   for(i=0; i<BuyOrderCount-1; i++)
     {
      for(j=i+1; j<BuyOrderCount; j++)
        {
         if(BuyOrders[i].lots>0 && BuyOrders[j].lots>0)
           {
            // at least 2 orders
            if(BuyOrders[j].lots<BuyOrders[i].lots)
              {
               // sorting
               tmp=BuyOrders[i];
               BuyOrders[i]=BuyOrders[j];
               BuyOrders[j]= tmp;
              }
           }
        }
     }

// SELL ORDERS
   for(i=0; i<SellOrderCount-1; i++)
     {
      for(j=i+1; j<SellOrderCount; j++)
        {
         if(SellOrders[i].lots>0 && SellOrders[j].lots>0)
           {
            // at least 2 orders
            if(SellOrders[j].lots<SellOrders[i].lots)
              {
               // sorting...
               tmp=SellOrders[i];
               SellOrders[i]=SellOrders[j];
               SellOrders[j]= tmp;
              }
           }
        }
     }
//    if (SellOrderCount >0)print("!!!!",__FUNCTION__,": SellOrders[0].lots=" + SellOrders[0].lots);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SortByTicket()
  {
   int i,j;
   OrderInfoType tmp;

// We are going to sort orders by volume
// m[0] smallest volume m[size-1] largest volume

// BUY ORDERS
   for(i=0; i<BuyOrderCount-1; i++)
     {
      for(j=i+1; j<BuyOrderCount; j++)
        {
         if(BuyOrders[j].ticket<BuyOrders[i].ticket)
           {
            // sorting
            tmp=BuyOrders[i];
            BuyOrders[i]=BuyOrders[j];
            BuyOrders[j]= tmp;
           }
        }
     }

// SELL ORDERS
   for(i=0; i<SellOrderCount-1; i++)
     {
      for(j=i+1; j<SellOrderCount; j++)
        {
         if(SellOrders[j].ticket<SellOrders[i].ticket)
           {
            // sorting...
            tmp=SellOrders[i];
            SellOrders[i]=SellOrders[j];
            SellOrders[j]= tmp;
           }
        }
     }
//    if (SellOrderCount >0)print("!!!!",__FUNCTION__,": SellOrders[0].lots=" + SellOrders[0].lots);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SortByProfit()

  {
   int i,j;
   OrderInfoType tmp;

// We are going to sort orders by volume
// m[0] smallest volume m[size-1] largest volume

// BUY ORDERS
   for(i=0; i<BuyOrderCount-1; i++)
     {
      for(j=i+1; j<BuyOrderCount; j++)
        {
         //       if(BuyOrders[i].profit>0 && BuyOrders[j].profit>0)
           {
            // at least 2 orders
            if(BuyOrders[j].profit<BuyOrders[i].profit)
              {
               // sorting
               tmp=BuyOrders[i];
               BuyOrders[i]=BuyOrders[j];
               BuyOrders[j]= tmp;
              }
           }
        }
     }

// SELL ORDERS
   for(i=0; i<SellOrderCount-1; i++)
     {
      for(j=i+1; j<SellOrderCount; j++)
        {
         //      if(SellOrders[i].profit!=0 && SellOrders[j].profit>0)
           {
            // at least 2 orders
            if(SellOrders[j].profit<SellOrders[i].profit)
              {
               // sorting...
               tmp=SellOrders[i];
               SellOrders[i]=SellOrders[j];
               SellOrders[j]= tmp;
              }
           }
        }
     }
//    if (SellOrderCount >0)print("!!!!",__FUNCTION__,": SellOrders[0].lots=" + SellOrders[0].lots);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SortByTime()

  {
   int i,j;
   OrderInfoType tmp;

// We are going to sort orders by volume
// m[0] smallest volume m[size-1] largest volume

// BUY ORDERS
   for(i=0; i<BuyOrderCount-1; i++)
     {
      for(j=i+1; j<BuyOrderCount; j++)
        {
         //       if(BuyOrders[i].profit>0 && BuyOrders[j].profit>0)
           {
            // at least 2 orders
            if(BuyOrders[j].opentime<BuyOrders[i].opentime)
              {
               // sorting
               tmp=BuyOrders[i];
               BuyOrders[i]=BuyOrders[j];
               BuyOrders[j]= tmp;
              }
           }
        }
     }

// SELL ORDERS
   for(i=0; i<SellOrderCount-1; i++)
     {
      for(j=i+1; j<SellOrderCount; j++)
        {
         //      if(SellOrders[i].profit!=0 && SellOrders[j].profit>0)
           {
            // at least 2 orders
            if(SellOrders[j].opentime<SellOrders[i].opentime)
              {
               // sorting...
               tmp=SellOrders[i];
               SellOrders[i]=SellOrders[j];
               SellOrders[j]= tmp;
              }
           }
        }
     }
//    if (SellOrderCount >0)print("!!!!",__FUNCTION__,": SellOrders[0].lots=" + SellOrders[0].lots);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckMaxLossOrders(int mode,int seqcnt)
  {
   int i=0;
   bool ret=false;

   if(seqcnt <=0)
      return false;

   SortByProfit();
   if(mode==OP_BUY)
     {
      if(BuyOrderCount>=seqcnt)
        {
         ret=true;
         for(i=0; i<seqcnt; i++)
           {
            if(BuyOrders[i].profit>0)
              {
               ret=false;
               break;
              }
           }
        }
     }
   if(mode==OP_SELL)
     {
      if(SellOrderCount>=seqcnt)
        {
         ret=true;
         for(i=0; i<seqcnt; i++)
           {
            if(SellOrders[i].profit>0)
              {
               ret=false;
               break;
              }
           }
        }
     }
   SortByLots();
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderCloseReliableF(int ticket,double lots,double price,
                         int slippge,color arrow_color=CLR_NONE)
  {
   bool ok=OrderCloseReliable(ticket,lots,price,slippge,arrow_color);
//  if(IsTesting() && !IsOptimization()) LogOrder(ticket,TimeToStr(Time[0],TIME_DATE|TIME_MINUTES|TIME_SECONDS));
   return ok;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseAllMarketOrders(int typ,int magic)
  {
   int i;
   int cnt=0;
   bool closed=true;
   double price=0;
   RefreshRates();
   if(typ==OP_BUY)
     {
      for(i=0; i<=BuyOrderCount-1; i++)
        {
         price=MarketInfo(Symbol(),MODE_BID);
         //  price=OrderClosePrice();
         //       print(__FUNCTION__,StringFormat(": Close BUY Order #%d",BuyOrders[i].ticket));
         closed=OrderCloseReliableF(BuyOrders[i].ticket,BuyOrders[i].lots,price,slippage,Blue);
         if(closed)
            cnt++;
        }
      buy_max_profit=0;
      buy_close_profit=0;

     }
   if(typ==OP_SELL)
     {
      for(i=0; i<=SellOrderCount-1; i++)
        {
         price=MarketInfo(Symbol(),MODE_ASK);
         // price=OrderClosePrice();
         //        print(__FUNCTION__,StringFormat(": Close SELL Order #%d",SellOrders[i].ticket));
         closed=OrderCloseReliableF(SellOrders[i].ticket,SellOrders[i].lots,price,slippage,Red);
         if(closed)
            cnt++;
        }
      sell_max_profit=0;
      sell_close_profit=0;

     }
   UpdateOrderlist(magic);
   return cnt;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseAllLossOrders(int typ,int stoppips,int magic)
  {
   int i;
   int cnt=0;
   bool closed=true;
   double price=0;
   if(typ==OP_BUY)
     {
      for(i=0; i<=BuyOrderCount-1; i++)
        {
         if(BuyOrders[i].profit<0)
           {
            price=MarketInfo(Symbol(),MODE_BID);
            if(BuyOrders[i].price-price>stoppips*Point)
              {

               // price=OrderClosePrice();
               print(__FUNCTION__,StringFormat(": Close BUY Order #%d",BuyOrders[i].ticket));
               closed=OrderCloseReliableF(BuyOrders[i].ticket,BuyOrders[i].lots,price,slippage,Blue);
               if(closed)
                  cnt++;
              }
           }
        }
      // BuyResetAfterClose();
     }
   if(typ==OP_SELL)
     {
      for(i=0; i<=SellOrderCount-1; i++)
        {
         if(SellOrders[i].profit<0)
           {
            price=MarketInfo(Symbol(),MODE_ASK);
            if(price-SellOrders[i].price>stoppips*Point)
              {
               //    price=OrderClosePrice();
               print(__FUNCTION__,StringFormat(": Close SELL Order #%d",SellOrders[i].ticket));
               closed=OrderCloseReliableF(SellOrders[i].ticket,SellOrders[i].lots,price,slippage,Red);
               if(closed)
                  cnt++;
              }
           }
        }
      // At this point all orders are closed. Global vars will be updated thanks to UpdateVars() on next start() execution
      //    SellResetAfterClose();
     }
   UpdateOrderlist(magic);
   return cnt;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseAllWinOrders(int typ,int takeprofitppis,int magic)
  {
   int i;
   int cnt=0;
   bool closed=true;
   double price=0;
   if(typ==OP_BUY)
     {
      for(i=0; i<=BuyOrderCount-1; i++)
        {
         if(BuyOrders[i].profit>takeprofitppis*Point)
           {
            price=MarketInfo(Symbol(),MODE_BID);
            //   price=OrderClosePrice();
            print(__FUNCTION__,StringFormat(": Close BUY Order #%d",BuyOrders[i].ticket));
            closed=OrderCloseReliableF(BuyOrders[i].ticket,BuyOrders[i].lots,price,slippage,Blue);
            if(closed)
               cnt++;
           }
        }
      // BuyResetAfterClose();
     }
   if(typ==OP_SELL)
     {
      for(i=0; i<=SellOrderCount-1; i++)
        {
         if(SellOrders[i].profit>takeprofitppis*Point)
           {
            price=MarketInfo(Symbol(),MODE_ASK);
            //   price=OrderClosePrice();
            print(__FUNCTION__,StringFormat(": Close SELL Order #%d",SellOrders[i].ticket));
            closed=OrderCloseReliableF(SellOrders[i].ticket,SellOrders[i].lots,price,slippage,Red);
            if(closed)
               cnt++;
           }
        }
      // At this point all orders are closed. Global vars will be updated thanks to UpdateVars() on next start() execution
      //    SellResetAfterClose();
     }
   UpdateOrderlist(magic);
   return cnt;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MaxOrdersAge(OrderInfoType &list[],int len,int shift)
  {
   int ret=0;
   datetime d=0;  // datetime type (an integer that represents the number of seconds elapsed from 0 hours of January 1, 1970).
   for(int i = 0; i < len; i++)
     {
      d=Time[shift]-list[i].opentime;
      if((int)d>ret)
         ret=(int)d;
     }
   return ret;
  }
//+------------------------------------------------------------------+
//|    Order Age in Sekunden                                         |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderAge(OrderInfoType &order)
  {
   datetime now=TimeCurrent();
   datetime ret=now-order.opentime;;
   MqlDateTime dt_order;
   MqlDateTime dt_now;

   bool ok=TimeToStruct(order.opentime,dt_order);
   if(ok)
     {
      ok=TimeToStruct(now,dt_now);
      if(ok)
        {
         if(dt_now.day_of_week<dt_order.day_of_week)
           {
            ret=ret-48*60*60;
           }
        }
     }
//  Print(__FUNCTION__,StringFormat(": ret=%d",ret));
   return (int)ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int findMaxLossTicket(int mode)
  {
   int i;
   double maxloss=0,val=0;
   int maxlossticket=-1;
   if(mode==OP_BUY)
     {
      for(i=0; i<BuyOrderCount; i++)
        {

         val=BuyOrders[i].profit;
         if(val<0)
           {
            val=-val;
            if(val>maxloss)
              {
               maxloss=val;
               maxlossticket=BuyOrders[i].ticket;
              }
           }
        }
     }
   if(mode==OP_SELL)
     {
      for(i=0; i<SellOrderCount; i++)
        {

         val=SellOrders[i].profit;
         if(val<0)
           {
            val=-val;
            if(val>maxloss)
              {
               maxloss=val;
               maxlossticket=SellOrders[i].ticket;
              }
           }
        }
     }
   return maxlossticket;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int findMaxLossTicketIndex(int mode)
  {
   int i;
   double maxloss=0,val=0;
   int index=-1;
   if(mode==OP_BUY)
     {
      for(i=0; i<BuyOrderCount; i++)
        {

         val=BuyOrders[i].profit;
         if(val<0)
           {
            val=-val;
            if(val>maxloss)
              {
               maxloss=val;
               index=i;
              }
           }
        }
     }
   if(mode==OP_SELL)
     {
      for(i=0; i<SellOrderCount; i++)
        {

         val=SellOrders[i].profit;
         if(val<0)
           {
            val=-val;
            if(val>maxloss)
              {
               maxloss=val;
               index=i;
              }
           }
        }
     }
   return index;
  }
  
datetime findLastOpenIndex(int mode)
  {
   int i;
   datetime opentime =0;
   int index = 0;
   if(mode==OP_BUY)
     {
      for(i=0; i<BuyOrderCount; i++)
        {
         if(BuyOrders[i].opentime >opentime)
           {
            opentime=BuyOrders[i].opentime;
            index = i;
           }
        }
     }
   if(mode==OP_SELL)
     {
      for(i=0; i<SellOrderCount; i++)
        {
         if(SellOrders[i].opentime >opentime)
           {
            opentime=SellOrders[i].opentime;
            index = i;
           }
        }
     }
   return index;
  }  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LastOrderOpenPrice(int mode)
  {
   int i;
   double price=0;
   datetime opentime =0;
   if(mode==OP_BUY)
     {
      for(i=0; i<BuyOrderCount; i++)
        {
         if(BuyOrders[i].opentime >opentime)
           {
            price=BuyOrders[i].price;
            opentime=BuyOrders[i].opentime;
           }
        }
     }
   if(mode==OP_SELL)
     {
      for(i=0; i<SellOrderCount; i++)
        {
         if(SellOrders[i].opentime >opentime)
           {
            price=SellOrders[i].price;
            opentime=SellOrders[i].opentime;
           }
        }
     }
   return price;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime LastOrderOpenTime(int mode)
  {
   int i;
   datetime opentime =0;
   if(mode==OP_BUY)
     {
      for(i=0; i<BuyOrderCount; i++)
        {
         if(BuyOrders[i].opentime >opentime)
           {
            opentime=BuyOrders[i].opentime;
           }
        }
     }
   if(mode==OP_SELL)
     {
      for(i=0; i<SellOrderCount; i++)
        {
         if(SellOrders[i].opentime >opentime)
           {
            opentime=SellOrders[i].opentime;
           }
        }
     }
   return opentime;
  }
//+------------------------------------------------------------------+
int LastOrderOpenBar(int mode)
  {
   datetime t = LastOrderOpenTime(mode);
   int ret = iBarShift(NULL,0,t,false);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime LastOrderCloseTime(int mode)
  {
   int i;

   datetime time =0;
   int hstTotal=OrdersHistoryTotal();
   for(i=0; i<hstTotal; i++)
     {
      //---- check selection result
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
        {
         break;
        }
      if(OrderType() == mode)
        {
         if(OrderSymbol() == Symbol())
           {
            if(OrderCloseTime() >time)
              {
               time=OrderCloseTime() ;
              }
           }
        }
     }


   return time;
  }
//+------------------------------------------------------------------+
int LastOrderCloseBar(int mode)
  {
   datetime t = LastOrderCloseTime(mode);
   int ret = iBarShift(NULL,0,t,false);
   return ret;
  }