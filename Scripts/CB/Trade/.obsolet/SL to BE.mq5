// #property copyright "Drop on chart at requested SL Price"
extern int           MagicNumber =0;
extern double       WHENTOMOVETOBE = 10;    //When to move break even
extern double       PIPSTOMOVESL = 10;      //How much PIPS() to move sl
#include <cb\CB_OrderMachine.mqh>

#include <cb\CB_Commons.mqh>
#property script_show_inputs

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnStart()
  {
     COrderMachine OM;
     OM.Init();
     OM.OrderSetStop(MagicNumber,PIPSTOMOVESL,WHENTOMOVETOBE);
     OM.Deinit();
     return 0;
  }


//+------------------------------------------------------------------+
/********************
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MOVETOBREAKEVEN()
  {
   string msg = "";
   double price=0;
// Print(__FUNCTION__,":OrdersTotal=",OrdersTotal());
   for(int b = OrdersTotal() - 1; b >= 0; b--)
     {
      if(OrderSelect(b, SELECT_BY_POS, MODE_TRADES))
         if(OrderMagicNumber() != MagicNumber && MagicNumber!=0)
            continue;
      if(OrderSymbol() == Symbol())
        {
         if(OrderType() == OP_BUY)
           {
            if(Bid - OrderOpenPrice() > WHENTOMOVETOBE * POINT)
              {
               if(OrderOpenPrice() > OrderStopLoss())
                 {
                  msg="OK!";
                  price =  OrderOpenPrice() + (PIPSTOMOVESL * POINT);
                  if(!OrderModify(OrderTicket(), OrderOpenPrice(),price, OrderTakeProfit(), 0, CLR_NONE))
                    {
                     msg = ErrorMsg();
                    }
                 }
               Alert(__FUNCTION__, ": BUY Order #", OrderTicket() + " ==>" + (string) price + " result="  + msg);
              }
           }
        }
     }

   for(int s = OrdersTotal() - 1; s >= 0; s--)
     {
      if(OrderSelect(s, SELECT_BY_POS, MODE_TRADES))
         if(OrderMagicNumber() != MagicNumber && MagicNumber!=0)
            continue;
      if(OrderSymbol() == Symbol())
        {
         if(OrderType() == OP_SELL)
           {
            if(OrderOpenPrice() - Ask > WHENTOMOVETOBE * POINT)
              {
               if(OrderOpenPrice() < OrderStopLoss())
                 {
                  msg = "OK!";
                  price = OrderOpenPrice() - (PIPSTOMOVESL * POINT);
                  if(!OrderModify(OrderTicket(), OrderOpenPrice(), price, OrderTakeProfit(), 0, CLR_NONE))
                    {
                     msg = ErrorMsg();
                    }
                  Alert(__FUNCTION__, ": SELL Order #", OrderTicket() + " ==>" +(string) price + " result="  + msg);
                 }
              }
           }
        }
     }
  }
******/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ErrorMsg()
  {
   int err = GetLastError();
   string txt = "ERROR: " + ErrorDescription(err);
   return txt;
  }
//+------------------------------------------------------------------+
