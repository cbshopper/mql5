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
bool ModifyStopLoss(int ticket, double xStopLoss)
  {
   bool ok=OrderModify(ticket,OrderOpenPrice(ticket),xStopLoss,OrderTakeProfit(ticket),0,CLR_NONE);
   if(!ok)
     {
      int error=GetLastError();
      Print(__FUNCTION__," Order #"+(string)ticket+" Error = ",ErrorDescription(error));
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ModifyTakeProfit(int ticket, double idTakeProfit)
  {
   bool ok=OrderModify(ticket,OrderOpenPrice(ticket),OrderStopLoss(ticket),idTakeProfit,0,CLR_NONE);
   if(!ok)
     {
      int error=GetLastError();
      Print(__FUNCTION__," Order #"+(string)ticket+" Error = ",ErrorDescription(error));
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ModifyStopLossAndTakeProfit(int ticket,double idStopLoss,double idTakeProfit)
  {
   bool ok=OrderModify(ticket,OrderOpenPrice(ticket),idStopLoss,idTakeProfit,0,CLR_NONE);
   if(!ok)
     {
      int error=GetLastError();
      Print(__FUNCTION__," Order #"+(string)ticket+" Error = ",ErrorDescription(error));
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderSetStop(string symbol,int magic,int StoppLoss)
  {
   int cnt;
   bool ret=true;
   bool ok=false;
   int error=0;
   double buyStopPrice=0;
   double sellStopPrice=0;
   double win=0;

   int total=OrdersTotal();
   for(cnt=0; cnt<total; cnt++)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType()<=OP_SELL && // check for opened position
            (OrderSymbol()==symbol || symbol=="") && // check for symbol
            OrderMagicNumber()==magic) // check for magic
           {
            double pp=PPP(); //MarketInfo(OrderSymbol(),MODE_POINT);

            StoppLoss=CheckStopLossPips(OrderSymbol(),StoppLoss);
            sellStopPrice=MarketInfo(OrderSymbol(),MODE_ASK)+pp*StoppLoss;
            buyStopPrice=MarketInfo(OrderSymbol(),MODE_BID)-pp*StoppLoss;
            sellStopPrice = CheckPriceVal(sellStopPrice);
            buyStopPrice = CheckPriceVal(buyStopPrice);

            if(StoppLoss>0)
              {
               if(OrderType()==OP_BUY) // long position is opened
                 {
                  if(OrderStopLoss()==0)
                    {
                     Print(__FUNCTION__," TrailingStop="+(string)StoppLoss);
                     ok=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(buyStopPrice,4),OrderTakeProfit(),0,Green);
                     if(!ok)
                       {
                        error=GetLastError();
                        Print(__FUNCTION__," Order #"+(string)OrderTicket()+" Error = ",ErrorDescription(error));
                        ret=false;
                       }
                    }
                 }
               if(OrderType()==OP_SELL) // short position is opened
                 {
                  if(OrderStopLoss()==0)
                    {
                     Print(__FUNCTION__," TrailingStop="+(string)StoppLoss);
                     ok=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(sellStopPrice,4),OrderTakeProfit(),0,Red);
                     if(!ok)
                       {
                        error=GetLastError();
                        Print(__FUNCTION__," Order #"+(string)OrderTicket()+" Error = ",ErrorDescription(error));
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
bool PendingOrderSetTPandSL(string symbol,int magic,int StoppLoss,int TakeProfit)
  {
   int cnt;
   bool ret=true;

   int total=OrdersTotal();
   for(cnt=0; cnt<total; cnt++)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType()>OP_SELL && // check for opened position
            (OrderSymbol()==symbol || symbol=="") && // check for symbol
            OrderMagicNumber()==magic) // check for magic
           {
            bool ok =  pendingOrderSetTPSL(OrderTicket(),StoppLoss,TakeProfit);
            if(!ok)
               ret=false;
           }
        }
     }
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool pendingOrderSetTPSL(int ticket, int StoppLoss, int TakeProfit)
  {
   bool ret=true;
   bool ok=false;
   int error=0;
   double buyStopPrice=0;
   double sellStopPrice=0;
   double buyTPPrice=0;
   double sellTPPrice=0;
   double win=0;
   if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
     {
      double pp=PPP(); //MarketInfo(OrderSymbol(),MODE_POINT);
      // pp = MarketInfo(OrderSymbol(),MODE_POINT);
      if(StoppLoss>0)
        {
         StoppLoss=CheckStopLossPips(OrderSymbol(),StoppLoss);
         sellStopPrice=OrderOpenPrice()+pp*StoppLoss;
         buyStopPrice=OrderOpenPrice()-pp*StoppLoss;
        }
      else
        {
         buyStopPrice=OrderStopLoss();
         sellStopPrice=OrderStopLoss();
        }
      if(TakeProfit>0)
        {
         TakeProfit=CheckStopLossPips(OrderSymbol(),TakeProfit);
         sellTPPrice=OrderOpenPrice()-pp*TakeProfit;
         buyTPPrice=OrderOpenPrice()+pp*TakeProfit;
        }
      else
        {
         sellTPPrice=OrderTakeProfit();
         buyTPPrice=OrderTakeProfit();
        }
      Print(__FUNCTION__," 1 StoppLoss="+(string)StoppLoss," TakeProfit="+(string)TakeProfit);
      Print(__FUNCTION__," 1 buyStopPrice="+(string)buyStopPrice," sellStopPrice="+(string)sellStopPrice);
      sellStopPrice = CheckPriceVal(sellStopPrice);
      buyStopPrice = CheckPriceVal(buyStopPrice);


      sellTPPrice = CheckPriceVal(sellTPPrice);
      buyTPPrice = CheckPriceVal(buyTPPrice);
      Print(__FUNCTION__," 2 buyStopPrice="+(string)buyStopPrice," sellStopPrice="+(string)sellStopPrice);


      if(StoppLoss>0 || TakeProfit>0)
        {
         if(OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP) // long position is opened
           {
            if(OrderStopLoss()==0 || OrderTakeProfit()==0)
              {
               Print(__FUNCTION__," TrailingStop="+(string)StoppLoss," TakeProfit="+(string)TakeProfit);
               ok=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(buyStopPrice,4),NormalizeDouble(buyTPPrice,4),0,Green);
               if(!ok)
                 {
                  error=GetLastError();
                  Print(__FUNCTION__," Order #"+(string)OrderTicket()+" Error = ",ErrorDescription(error));
                  ret=false;
                 }
              }
           }
         if(OrderType()==OP_SELLLIMIT || OrderType()==OP_SELLSTOP) // short position is opened
           {
            if(OrderStopLoss()==0 || OrderTakeProfit()==0)
              {
               Print(__FUNCTION__," TrailingStop="+(string)StoppLoss);
               ok=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(sellStopPrice,4),NormalizeDouble(sellTPPrice,4),0,Red);
               if(!ok)
                 {
                  error=GetLastError();
                  Print(__FUNCTION__," Order #"+(string)OrderTicket()+" Error = ",ErrorDescription(error));
                  ret=false;
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
bool OrderSimpleTrailingStop(string symbol,int magic,int TrailingStop)
  {
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
         continue;

      if(OrderType() >OP_SELL || // check for opened position
         (OrderSymbol()!=symbol) || // check for symbol
         OrderMagicNumber()!=magic) // check for magic
         continue;
      if(OrderType()==OP_BUY)
        {
         if(Bid-OrderOpenPrice()>Point*TrailingStop)
           {
            if(OrderStopLoss()<Bid-Point*TrailingStop)
              {
               OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*TrailingStop,OrderTakeProfit(),0,Green);
               return(0);
              }
           }
        }
      if(OrderType()==OP_SELL)
        {
         if((OrderOpenPrice()-Ask)>(Point*TrailingStop))
           {
            if((OrderStopLoss()>(Ask+Point*TrailingStop)) || (OrderStopLoss()==0))
              {
               OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*TrailingStop,OrderTakeProfit(),0,Red);
               return(0);
              }
           }
        }
      }
      return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderSetTStop(string symbol,int magic,int trailingStop,int MinWinTicks)
  {
   int cnt;
   bool ret=true;
   bool ok=false;
   int error=0;
   double buyStopPrice=0;
   double sellStopPrice=0;
   double win=0;

   int total=OrdersTotal();
   for(cnt=0; cnt<total; cnt++)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType()<=OP_SELL && // check for opened position
            (OrderSymbol()==symbol || symbol=="") && // check for symbol
            OrderMagicNumber()==magic) // check for magic
           {
            double pp=PPP(); //MarketInfo(OrderSymbol(),MODE_POINT);

            trailingStop=CheckStopLossPips(OrderSymbol(),trailingStop);
            sellStopPrice=MarketInfo(OrderSymbol(),MODE_ASK)+pp*trailingStop;
            buyStopPrice=MarketInfo(OrderSymbol(),MODE_BID)-pp*trailingStop;
            sellStopPrice = CheckPriceVal(sellStopPrice);
            buyStopPrice = CheckPriceVal(buyStopPrice);

            if(trailingStop>0)
              {
               if(OrderType()==OP_BUY) // long position is opened
                 {
                  // check for trailing stop
                  win=MarketInfo(OrderSymbol(),MODE_BID)-OrderOpenPrice();

                  Print(__FUNCTION__," win=",win, " pp*tralingStop=",pp*trailingStop," (win>pp*MinWinTicks || MinWinTicks==0 || OrderStopLoss()!=0)=",win>pp*MinWinTicks || MinWinTicks==0 || OrderStopLoss()!=0);
                  //   if((win>pp*trailingStop && (win>pp*MinWinTicks || MinWinTicks==0 || OrderStopLoss()!=0)))
                  if(Bid-OrderOpenPrice()>buyStopPrice)
                    {
                     if((OrderStopLoss()<buyStopPrice) || (OrderStopLoss()==0))
                       {
                        Print(__FUNCTION__," TrailingStop="+(string)trailingStop);
                        ok=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(buyStopPrice,4),OrderTakeProfit(),0,Green);
                        if(!ok)
                          {
                           error=GetLastError();
                           Print(__FUNCTION__," Order #"+(string)OrderTicket()+" Error = ",ErrorDescription(error));
                           ret=false;
                          }
                        //     return(0);
                       }
                    }
                 }
               if(OrderType()==OP_SELL) // short position is opened
                 {
                  // check for trailing stop
                  win=OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK);
                  // if((win>pp*trailingStop && (win>pp*MinWinTicks || MinWinTicks==0 || OrderStopLoss()!=0)))
                  if((OrderOpenPrice()-Ask)>sellStopPrice)
                    {
                     if((OrderStopLoss()>(sellStopPrice)) || (OrderStopLoss()==0))
                       {
                        Print(__FUNCTION__," TrailingStop="+(string)trailingStop);
                        ok=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(sellStopPrice,4),OrderTakeProfit(),0,Red);
                        if(!ok)
                          {
                           error=GetLastError();
                           Print(__FUNCTION__," Order #"+(string)OrderTicket()+" Error = ",ErrorDescription(error));
                           ret=false;
                          }
                        //            return(0);
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
bool OrderSetTStopAbs(string symbol,int magic,double Val)
  {
   int cnt;
   bool ret=true;
   bool ok=false;
   int error=0;
   double buyStopPrice=0;
   double sellStopPrice=0;
   double win=0;

   int total=OrdersTotal();
   for(cnt=0; cnt<total; cnt++)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType()<=OP_SELL && // check for opened position
            (OrderSymbol()==symbol || symbol=="") && // check for symbol
            OrderMagicNumber()==magic) // check for magic
           {
            if(Val>0)
              {
               Print(__FUNCTION__," TrailingStopValue="+(string)Val);
               ok=OrderModify(OrderTicket(),OrderOpenPrice(),Val,OrderTakeProfit(),0,Green);
               if(!ok)
                 {
                  error=GetLastError();
                  Print(__FUNCTION__," Order #"+(string)OrderTicket()+" Error = ",ErrorDescription(error));
                  ret=false;
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
int OrderSetTP(string symbol,int Magic,int TakeProfitPips,bool remove)
  {
   int itotal=OrdersTotal();
   double price=0;
   for(int cnt=itotal-1; cnt>=0; cnt--)
     {
      bool ok=OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);

      if(ok)
        {
         if((OrderSymbol()==symbol || symbol=="") && OrderMagicNumber()==Magic)
           {

            double pp=PPP(); //MarketInfo(OrderSymbol(),MODE_POINT);
            if(OrderType()==OP_BUY)
              {
               if(remove)
                 {
                  ModifyTakeProfit(0);
                 }
               else
                 {
                  price=MarketInfo(OrderSymbol(),MODE_ASK)+TakeProfitPips*pp;
                  if(OrderTakeProfit()==0)
                    {
                     Print(__FUNCTION__," TakeProfitPips="+(string)TakeProfitPips);
                     ModifyTakeProfit(price);
                    }
                 }
              }

            if(OrderType()==OP_SELL)
              {
               if(remove)
                 {
                  ModifyTakeProfit(0);
                 }
               else
                 {
                  price=MarketInfo(OrderSymbol(),MODE_BID)-TakeProfitPips*pp;
                  if(OrderTakeProfit()==0)
                    {
                     Print(__FUNCTION__," TakeProfitPips="+(string)TakeProfitPips);
                     ModifyTakeProfit(price);
                    }
                 }
              }
           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SetTP(int TakeProfitPips)
  {
   return OrderSetTP(Symbol(),0,TakeProfitPips,false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SetSL(int TakeProfitPips)
  {
   return OrderSetTStop(Symbol(),0,TakeProfitPips,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseAllOpenOrders(int Magic,int ordertype)
  {
   int ret=0;
   int total= OrdersTotal();
   for(int i=total-1; i>=0; i--)
     {
      bool ok=OrderSelect(i,SELECT_BY_POS);
      if(ok)
        {
         int type=OrderType();
         if(Magic!=0 && OrderMagicNumber()!=Magic)
            continue;
         bool result=false;

         switch(type)
           {
            //Close opened long positions
            case OP_BUY       :
               if(ordertype==OP_BUY || ordertype==-1)
                 {
                  result=OrderCloseReliable(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,Red);
                 }
               break;

            //Close opened short positions
            case OP_SELL      :
               if(ordertype==OP_SELL || ordertype==-1)
                 {
                  result=OrderCloseReliable(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,Red);
                 }
               break;

               //Close pending orders
           }

         if(result==false)
           {
            Alert("Order ",OrderTicket()," failed to close. Error:",GetLastError());
            Sleep(3000);
            ret=1;
           }
        }
     }
   return(ret);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseAllOpenOrdersX(int Magic,int ordertype,bool reverse)
  {
   int ret=0;
   double lots=0;
   double price=0;
   int magic=0;
   string comment="";
   int newticket;
   int ticket=0;
   int error;

   int total= OrdersTotal();
   for(int i=total-1; i>=0; i--)
     {
      bool ok=OrderSelect(i,SELECT_BY_POS);
      if(ok)
        {
         int type=OrderType();
         ticket=OrderTicket();
         lots=OrderLots();
         comment=OrderComment()+" (reverse)";
         magic=OrderMagicNumber();

         if(Magic!=0 && OrderMagicNumber()!=Magic)
            continue;
         bool result=false;
         double win=OrderProfit();
         //    Print(__FUNCTION__, ": Order #", ticket," Win=",win);
         switch(type)
           {
            //Close opened long positions
            case OP_BUY       :
               if(ordertype==OP_BUY || ordertype==-1)
                 {
                  //             Print(__FUNCTION__,": TRY CLOSE BUY Order #"+(string)ticket+" at price ", price);
                  price=MarketInfo(OrderSymbol(),MODE_BID);
                  // result=OrderCloseReliable(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,Red);
                  result=OrderCloseReliable(ticket,lots,price,5,Red);
                  //                 result=OrderCloseReliable(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),5,Red);
                  if(result)
                    {
                     ret++;
                     //                 Print(__FUNCTION__,": BUY Order #"+(string)ticket+" closed!");
                     if(reverse)
                       {
                        if(win<0)
                          {
                           newticket=OrderSend(Symbol(),OP_SELL,lots,price,7,0,0,comment,magic,0,CLR_NONE);
                           Print(__FUNCTION__,": open reverse SELL Order #",(string)newticket," from closed Order #",(string)ticket);
                           result=newticket>-1;
                          }
                       }
                    }
                  else
                    {
                     error=GetLastError();
                     Print(__FUNCTION__,": Order #"+(string)ticket+" Error = ",ErrorDescription(error));
                    }
                 }
               break;

            //Close opened short positions
            case OP_SELL      :
               if(ordertype==OP_SELL || ordertype==-1)
                 {
                  price=MarketInfo(OrderSymbol(),MODE_ASK);
                  //              Print(__FUNCTION__,": TRY CLOSE SELL Order #"+(string)ticket+" at price ", price);
                  //result=OrderCloseReliable(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,Red);
                  result=OrderCloseReliable(ticket,lots,price,5,Red);
                  //                    result=OrderCloseReliable(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),5,Red);
                  if(result)
                    {
                     ret++;
                     //                 Print(__FUNCTION__,": SELL Order #"+(string)ticket+" closed!");
                     if(reverse)
                       {
                        if(win<0)
                          {
                           newticket=OrderSend(Symbol(),OP_BUY,lots,price,7,0,0,comment,magic,0,CLR_NONE);
                           Print(__FUNCTION__,": open reverse BUY Order #",(string)newticket," from closed Order #",(string)ticket);
                           result=newticket>-1;
                          }
                       }
                    }
                  else
                    {
                     error=GetLastError();
                     Print(__FUNCTION__,": Order #"+(string)ticket+" Error = ",ErrorDescription(error));
                    }
                 }
               break;

               //Close pending orders
           }
         /*
                  if(result==false)
                    {
                     Alert("Order ",OrderTicket()," failed to close. Error:",GetLastError());
                     Sleep(3000);
                     ret=1;
                    }
                    */
        }
     }
//  Print(__FUNCTION__,": Number of closed orders:",ret);
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseAllOpenOrders()
  {
   return  CloseAllOpenOrders(0,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CloseAllPendingOrders(int Magic,int ordertype)
  {
   int total= OrdersTotal();
   for(int i=total-1; i>=0; i--)
     {
      bool ok =OrderSelect(i,SELECT_BY_POS);
      int type=OrderType();
      if(Magic!=0 && OrderMagicNumber()!=Magic)
         continue;
      bool result=false;

      switch(type)
        {
         //Close pending orders
         case OP_BUYLIMIT  :
         case OP_BUYSTOP   :
         case OP_SELLLIMIT :
         case OP_SELLSTOP  :
            if(type==ordertype || ordertype==-1)
              {
               result=OrderDelete(OrderTicket());
              }
            else
              {
               result=true;
              }
        }

      if(result==false)
        {
         Alert("Order ",OrderTicket()," failed to close. Error:",GetLastError());
         Sleep(3000);
        }
     }

   return(0);
  }



//+------------------------------------------------------------------+
bool DeleteAllOrders(string symbol,int ordertype,int magic)
  {
   int cnt,total;
   bool ret=true;
   total=OrdersTotal();
   Print(__FUNCTION__);
   for(cnt=total-1; cnt>=0; cnt--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {

      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderMagicNumber()==magic &&
            OrderType()==ordertype &&
            OrderSymbol()==symbol)
           {
            if(!OrderDelete(OrderTicket()))
              {
               ret=false;
              }

           }
        }
      else
        {
         ret=false;
        }
     }
   return ret;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderSetStopT(string symbol,int magic,int StoppLoss,datetime Starttime)
  {
   int cnt;
   ;
   bool ret=true;
   int total=OrdersTotal();
   for(cnt=0; cnt<total; cnt++)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType()<=OP_SELL && // check for opened position
            (OrderSymbol()==symbol || symbol=="") && // check for symbol
            OrderMagicNumber()==magic) // check for magic
           {
            if(OrderOpenTime() > Starttime || Starttime == 0)
               ret = setOrderStop(OrderTicket(),StoppLoss);
           }
        }
     }
   return ret;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool setOrderStop(int ticket, int StoppLoss)
  {
   bool ret=true;
   bool ok=false;
   int error=0;
   double buyStopPrice=0;
   double sellStopPrice=0;
   double win=0;
   if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
     {
      double pp=PPP(); //double pp=MarketInfo(OrderSymbol(),MODE_POINT);

      StoppLoss=CheckStopLossPips(OrderSymbol(),StoppLoss);
      sellStopPrice=MarketInfo(OrderSymbol(),MODE_ASK)+pp*StoppLoss;
      buyStopPrice=MarketInfo(OrderSymbol(),MODE_BID)-pp*StoppLoss;
      sellStopPrice = CheckPriceVal(sellStopPrice);
      buyStopPrice = CheckPriceVal(buyStopPrice);
      if(StoppLoss>0)
        {

         if(OrderType()==OP_BUY) // long position is opened
           {
            if(OrderStopLoss()==0)
              {
               Print(__FUNCTION__," TrailingStop="+(string)StoppLoss);
               ok=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(buyStopPrice,4),OrderTakeProfit(),0,Green);
               if(!ok)
                 {
                  error=GetLastError();
                  Print(__FUNCTION__," Order #"+(string)OrderTicket()+" Error = ",ErrorDescription(error));
                  ret=false;
                 }
              }
            return ret;  // Exit and calculate lots for next!
           }
         if(OrderType()==OP_SELL) // short position is opened
           {
            if(OrderStopLoss()==0)
              {
               Print(__FUNCTION__," TrailingStop="+(string)StoppLoss);
               ok=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(sellStopPrice,4),OrderTakeProfit(),0,Red);
               if(!ok)
                 {
                  error=GetLastError();
                  Print(__FUNCTION__," Order #"+(string)OrderTicket()+" Error = ",ErrorDescription(error));
                  ret=false;
                 }
              }
            return ret;  // Exit and calculate lots for next!
           }
        }
     }
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderSetTStopT(string symbol,int magic,int TrailingStop,int MinWinTicks,datetime Starttime)
  {
   int cnt;
   bool ret=true;


   int total=OrdersTotal();
   for(cnt=0; cnt<total; cnt++)
     {
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType()<=OP_SELL && // check for opened position
            (OrderSymbol()==symbol || symbol=="") && // check for symbol
            OrderMagicNumber()==magic) // check for magic
           {
            if(OrderOpenTime() > Starttime || Starttime == 0)
               ret = setOrderTStop(OrderTicket(),TrailingStop,MinWinTicks);
           }
        }
     }
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool setOrderTStop(int ticket, int TrailingStop,int MinWinTicks)
  {
   bool ret=true;
   int error=0;
   double buyStopPrice=0;
   double sellStopPrice=0;
   double win=0;
   bool ok=false;
   if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
     {
      double pp=PPP(); //double pp=MarketInfo(OrderSymbol(),MODE_POINT);

      TrailingStop=CheckStopLossPips(OrderSymbol(),TrailingStop);
      sellStopPrice=MarketInfo(OrderSymbol(),MODE_ASK)+pp*TrailingStop;
      buyStopPrice=MarketInfo(OrderSymbol(),MODE_BID)-pp*TrailingStop;
      sellStopPrice = CheckPriceVal(sellStopPrice);
      buyStopPrice = CheckPriceVal(buyStopPrice);
      if(TrailingStop>0)
        {
         if(OrderType()==OP_BUY) // long position is opened
           {
            // check for trailing stop
            win=MarketInfo(OrderSymbol(),MODE_BID)-OrderOpenPrice();
            if((win>pp*TrailingStop && (win>pp*MinWinTicks || MinWinTicks==0 || OrderStopLoss()!=0)))
              {
               if((OrderStopLoss()<buyStopPrice) || (OrderStopLoss()==0))
                 {
                  Print(__FUNCTION__," TrailingStop="+(string)TrailingStop);
                  ok=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(buyStopPrice,4),OrderTakeProfit(),0,Green);
                  if(!ok)
                    {
                     error=GetLastError();
                     Print(__FUNCTION__," Order #"+(string)OrderTicket()+" Error = ",ErrorDescription(error));
                     ret=false;
                    }
                  //     return(0);
                 }
              }
           }
         if(OrderType()==OP_SELL) // short position is opened
           {
            // check for trailing stop
            win=OrderOpenPrice()-MarketInfo(OrderSymbol(),MODE_ASK);
            if((win>pp*TrailingStop && (win>pp*MinWinTicks || MinWinTicks==0 || OrderStopLoss()!=0)))
              {
               if((OrderStopLoss()>(sellStopPrice)) || (OrderStopLoss()==0))
                 {
                  Print(__FUNCTION__," TrailingStop="+(string)TrailingStop);
                  ok=OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(sellStopPrice,4),OrderTakeProfit(),0,Red);
                  if(!ok)
                    {
                     error=GetLastError();
                     Print(__FUNCTION__," Order #"+(string)OrderTicket()+" Error = ",ErrorDescription(error));
                     ret=false;
                    }
                  //            return(0);
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
int OrderSetTPT(string symbol,int Magic,int TakeProfitPips,bool remove,datetime Starttime)
  {
   int itotal=OrdersTotal();
   for(int cnt=itotal-1; cnt>=0; cnt--)
     {
      bool ok=OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);

      if(ok)
        {
         if((OrderSymbol()==symbol || symbol=="") && OrderMagicNumber()==Magic)
           {
            if(OrderOpenTime() > Starttime || Starttime == 0)
               setOrderTPT(OrderTicket(),TakeProfitPips,remove);


           }
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setOrderTPT(int ticket,int TakeProfitPips,bool remove)
  {
   double price=0;

   if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
     {
      double pp=PPP(); //MarketInfo(OrderSymbol(),MODE_POINT);
      if(OrderType()==OP_BUY)
        {
         if(remove)
           {
            ModifyTakeProfit(0);
           }
         else
           {
            price=MarketInfo(OrderSymbol(),MODE_ASK)+TakeProfitPips*pp;
            price=CheckPriceVal(price);
            if(OrderTakeProfit()==0)
              {
               Print(__FUNCTION__," TakeProfitPips="+(string)TakeProfitPips);
               ModifyTakeProfit(price);
              }
           }
        }

      if(OrderType()==OP_SELL)
        {
         if(remove)
           {
            ModifyTakeProfit(0);
           }
         else
           {
            price=MarketInfo(OrderSymbol(),MODE_BID)-TakeProfitPips*pp;
            price=CheckPriceVal(price);
            if(OrderTakeProfit()==0)
              {
               Print(__FUNCTION__," TakeProfitPips="+(string)TakeProfitPips);
               ModifyTakeProfit(price);
              }
           }
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CheckPriceVal(double val)
  {
   double tval = MarketInfo(Symbol(),MODE_TICKSIZE);

// Print(__FUNCTION__,": Symbol()=",Symbol(),"  in=",val, " TickValue=",TickValue);

   val =val / tval;
   val = MathRound(val);
   val = val*tval;

//  Print(__FUNCTION__,": out=",val);

   return val;
  }
//+------------------------------------------------------------------+
