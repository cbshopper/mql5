// #property copyright "Drop on chart at requested SL Price"
#include <cb\CB_Commons.mqh>
#include <cb\CB_OrderChangers.mqh>
extern int           MagicNumber =0;
extern double       TRAILINGSTOP = 100;      //How much PIPS() to move sl

#property script_show_inputs

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnStart()
  {
     OrdersSetStop(MagicNumber,TRAILINGSTOP);
     return 0;
  }


//+------------------------------------------------------------------+
/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SETTRAILINGSTOP()
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
            if(Bid - OrderStopLoss() > TRAILINGSTOP * POINT)
              {
           //    if(OrderOpenPrice() > OrderStopLoss())
                 {
                  msg="OK!";
                  price = Bid - (TRAILINGSTOP * POINT);
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
            if(OrderStopLoss() - Ask > TRAILINGSTOP * POINT)
              {
        //       if(OrderOpenPrice() < OrderStopLoss())
                 {
                  msg = "OK!";
                  price = Ask + (TRAILINGSTOP * POINT);
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
*/
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
