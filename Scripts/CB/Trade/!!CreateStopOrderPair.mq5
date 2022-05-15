//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property script_show_inputs

#include <cb\CB_OrderMachine.mqh>


extern  string comment="";
extern double Lots=0.1;
extern int   Diff=25;
extern double Risk=1;
extern double CRV=2;
extern double Budget=10000;
extern int Slippage = 3;
extern int magicnumber=0;



int CalculateDiff()
{
  int diff =Diff;
  int digits = Digits();
  switch (digits)
  {
     case 0: diff*=1; break;
     case 1: diff*=1; break;
     case 2: diff*=10; break;
     case 3: diff*=100; break;
     case 4: diff*=1000; break;
  }
  return diff;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnStart()
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
   {
    Alert("Autotrade is NOT allowed.");
    return 0;
   }
  
   double minlots = MarketInfo(NULL,MODE_MINLOT);
   if(Lots < minlots)
      Lots = minlots;
   double realbudget = MathMin(AccountInfoDouble(ACCOUNT_BALANCE),AccountInfoDouble(ACCOUNT_EQUITY));   
   if(Budget == 0 || Budget > realbudget)
      Budget = realbudget;
      
   int mindiff = MarketInfo(NULL,MODE_STOPLEVEL);
   if (mindiff == 0) mindiff = 10;
   
   Diff=CalculateDiff();
   
   if(Diff <= mindiff)
      Diff = mindiff;

   double riskcaptial = Budget*Risk/100;

   int SL = calculateStopLossPoints(riskcaptial,Lots);
   int TP = SL*CRV;

   string msg = StringFormat("Open Buystop/Sellstop Pair: %f Lots, Diff=%d, SL=%d, TP=%d ?",Lots,Diff,SL,TP);

//  if(MessageBox(msg,WindowExpertName(),MB_YESNO|MB_ICONQUESTION)!=IDYES)
//     return(1);
//----
   double SPREAD = MarketInfo(NULL,MODE_SPREAD);
   double price=0;
   double openprice=0;
   double SLVal=0,TPVal=0;
// open Buystop Order
   price=Ask();
   openprice=NormalizeDouble(price+Diff*Point(),3);
   if(SL > 0)
      SLVal =  NormalizeDouble(openprice-(SL+SPREAD)*Point(),3);
   if(TP > 0)
      TPVal =  NormalizeDouble(openprice+(TP+SPREAD)*Point(),3);
   int ticket = OpenOrder(ORDER_TYPE_BUY_STOP,openprice,SLVal,TPVal);

   if(ticket > 0)
     {
      // open Sellstop Order
      price=Bid() ;
      openprice=NormalizeDouble(price-Diff*Point(),3);
      if(SL > 0)
         SLVal =  NormalizeDouble(openprice+(SL+SPREAD)*Point(),3);
      if(TP > 0)
         TPVal =  NormalizeDouble(openprice-TP*Point(),3);
      OpenOrder(ORDER_TYPE_SELL_STOP,openprice,SLVal,TPVal);

     }
//----

   return(0);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenOrder(int ordermode, double openprice,double SLVal, double TPVal)
  {
    COrderMachine OM ;
   OM.Init();
   string info =  ordermode+ " Lots=" + Lots +" Price=" + openprice +" SL=" + SLVal + " TP=" +TPVal;
   Print(__FUNCTION__," Open Order mode=" + info);
   int ticket=OM.OrderSend(Symbol(),
                        ordermode,
                        Lots,
                        openprice,
                        Slippage,
                        SLVal,
                        TPVal,
                        comment,
                        magicnumber,
                        0);

   if(ticket<1)
     {
      int err = GetLastError();
      PrintError(" Open Order mode=" + info);
     }
   else
     {
      if(OrderSelect(ticket))
        {
         double price = OrderGetDouble(ORDER_PRICE_OPEN);
         bool ok = OM.PositionModify(ticket,SLVal,TPVal);
         if(ok)
         {}
           // OrderPrint();
         else
           {
            PrintError(" Change Order mode=" + info);
            return 0;

           }
        }
      else
        {
         PrintError(" Select Order mode=" + info);
        }
     }
     OM.Deinit();
   
   return ticket;
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PrintError(string topic)
  {
   int error=GetLastError();
   string    msg= topic + "\nError = " + ErrorDescription(error);
   MessageBox(msg);
   Print(__FUNCTION__,msg);
  }
//+------------------------------------------------------------------+
