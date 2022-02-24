//+------------------------------------------------------------------+
//|                                               EABody.mqh |
//+------------------------------------------------------------------+

#include <cb\CB_Commons.mqh>
#include <cb\CB_OrderChangers.mqh>
// #include "CBOrderManager.mqh"
#include <cb\CB_SLTPCalculator.mqh>
int StopLossTicks=0;
int TakeProfitTicks=0;

extern int Expert_OnInit(int barcount=10);
extern int GetOpenSignal(int shift);
extern int GetCloseSignal(int shift, int mode,  int ticket);


enum ENUM_ORDERMODES
  {
   MODE_MARKET = 0,
   MODE_LIMIT = 1,
   MODE_STOP = 2

  };

input  string           COMMONS = "-------- Common EA Settings -------------";
int               START_SHIFT = 0;
bool              EtheryTick = false;
input ENUM_ORDERMODES   OrderMode = MODE_MARKET;
input int               PendingOrderDiffPips = 20;
input  int        PendingOrderExpireBarCount = 5;
input  double     Lots = 0.1;
int               Slippage       =   10;
input  int        MaxBuys = 10;
input  int        MaxSells = 10;
input  int        MaxOrdersTotal = 0;
//input  bool             OneOrderAtTime = false;
//int               MinOrderBarDiff = 0;

int               MaxSpread = 0;
input double      TotalEquityRisk = 0.0;    //Total Equity Risk

double AccountBalanceBeforeLoss = 0;

string VarEntrySignalName;
string VarExitSignalName;

datetime lastTradeTime = 0;
bool changed = false;
double POINT = Point();
int pendingOrderDiffPips;
string Program = "";

// EA BASIC Functions ===============================================+
//+------------------------------------------------------------------+
//| OnTick function                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

   Trade(START_SHIFT);
//---
  }
//+------------------------------------------------------------------+
int  OnInit()
  {
   Program = MQLInfoString(MQL_PROGRAM_NAME);
   int ret = Expert_OnInit();
   if(ret == INIT_SUCCEEDED)
     {
      Print(__FUNCTION__, ": ", __FILE__, " *****************************************************************************");
      int mindiff = MarketInfo(Symbol(), MODE_STOPLEVEL);
      pendingOrderDiffPips = PendingOrderDiffPips;
      if(pendingOrderDiffPips < mindiff)
        {
         pendingOrderDiffPips = mindiff;
        }
        
      POINT = Point();
      double money = AccountInfoDouble(ACCOUNT_BALANCE);

      if(money > MaxAccountValue && MaxAccountValue > 0)
         money = MaxAccountValue;

#ifdef TESTING
      EventSetTimer(2);
#endif
     }

   else
     {

     }
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   GlobalVariableDel(VarEntrySignalName);
   GlobalVariableDel(VarExitSignalName);
   Comment("");
   EventKillTimer();
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   OnTick();
  }

// EA MAIN Functions  ===============================================+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckPreConditions()
  {
   string msg = "";
//  if(IsTesting() || IsOptimization() || DEBUGMODE)
//     return ret;
#ifdef SCRIPT_TESTING
   return true;
#endif
   if(Bars < 100)
     {
      Print("bars less than 100");
      return false;
     }
   if(AllowTrading() == false)
     {
      msg = "No trading time.";
      Comment(msg);
      //   Print(__FUNCTION__,": ", msg);
      return false;
     }
   if(MaxSpread > 0)
     {
      int curspread = MathAbs(Ask() - Bid()) / Point();
      if(curspread > MaxSpread)
        {
         msg = StringFormat("Spread to high: %d (Max:%d)", curspread, MaxSpread);
         Comment(msg);
         Print(__FUNCTION__, ": ", msg);
         return false;
        }
     }
   return true;
  }
datetime LastActionTime = 0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trade(int shift)
  {
   bool isnewbar = false;

   datetime expireDate = 0;

   if(OrderMode != MODE_MARKET)
     {
      if(PendingOrderExpireBarCount > 0)
        {
         expireDate = TimeCurrent() +  PendingOrderExpireBarCount * PeriodSeconds(); // PendingOrderExpireHours*60*60  ;
         //    Print(__FUNCTION__,": ExpireDate=", expireDate);
        }
     }

   if(lastTradeTime < iTime(NULL,0,shift) || (EtheryTick && iTime(NULL,0,shift) > LastActionTime))
     {
      lastTradeTime = iTime(NULL,0,shift);
      isnewbar = true;
      changed = false;
     }
#ifdef TESTING
   isnewbar=true;
   changed=false;
#endif

   if(isnewbar)
     {
      changed = CheckForClose(shift);
      if(changed)
        {
         LastActionTime = iTime(NULL,0,shift);
        }
      if(CheckPreConditions())
        {
         if(AccountBalanceBeforeLoss < AccountInfoDouble(ACCOUNT_BALANCE))
           {
            AccountBalanceBeforeLoss = AccountInfoDouble(ACCOUNT_BALANCE);
           }

         changed = CheckForOpen(shift, OrderMode, pendingOrderDiffPips, expireDate);
         if(changed)
           {
            LastActionTime = iTime(NULL,0,shift);
           }

        }
      if(TrailingStop > 0)
        {
         //   Print(__FUNCTION__,": Set TrailingStop=",TrailingStop);
           PositionsSetStop(MagicNumber,TrailingStop);
        }
     }
  }

//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
bool CheckForOpen(int shift, ENUM_ORDERMODES mode, int DiffPips, datetime expire = 0)
  {
   int    res;
   int ordermode = 0;
   bool ret = false;
   double lots = 0;
   int lastbar = 0;
 
   OrderMachine.UpdateLists(MagicNumber);   // 1x bei jedem neuen Bar
   int OrderCnt = OrderMachine.SellPositionCount() + OrderMachine.BuyPositionCount();
   
   int signal = GetOpenSignal(shift);
   
  // lots = LotsOptimized(LotsIncreaseFactor, LotsRisk);
   lots = Lots;
  // signal=1;
//--- buy order
   if(signal > 0 && ((OrderMachine.BuyOrderCount() < MaxBuys && (OrderCnt < MaxOrdersTotal || MaxOrdersTotal == 0)) ||  mode != MODE_MARKET))
      //   if(signal>0 && ((BuyOrderCount<MaxBuys && !OneOrderAtTime) || (OrderCnt == 0 && OneOrderAtTime)))
     {
      if(CheckMoneyForTrade(Symbol(), lots, OP_BUY) == false)
         return false;
       Print(__FUNCTION__,": ***** BUY OrderCnt=",OrderCnt,": SellOrderCount=",OrderMachine.SellOrderCount(),": BuyOrderCount=",OrderMachine.BuyOrderCount());
      switch(mode)
        {
         case MODE_MARKET:
            ordermode = OP_BUY;
            break;
         case MODE_STOP:
            ordermode = OP_BUYSTOP;
            break;
         case MODE_LIMIT:
            ordermode = OP_BUYLIMIT;
            break;
        }
      ret = OpenBuyOrder(ordermode, DiffPips, lots, expire, shift);
     }
//--- sell order
   if(signal < 0 && ((OrderMachine.SellOrderCount() < MaxSells  && (OrderCnt < MaxOrdersTotal || MaxOrdersTotal == 0)) ||  mode != MODE_MARKET))
     {
      if(CheckMoneyForTrade(Symbol(), lots, OP_SELL) == false)
         return false;

      Print(__FUNCTION__,": **** SELL OrderCnt=",OrderCnt,": SellOrderCount=",OrderMachine.SellOrderCount(),": BuyOrderCount=",OrderMachine.BuyOrderCount());

      switch(mode)
        {
         case MODE_MARKET:
            ordermode = OP_SELL;
            break;
         case MODE_STOP:
            ordermode = OP_SELLSTOP;
            break;
         case MODE_LIMIT:
            ordermode = OP_SELLLIMIT;
            break;
        }
      ret = OpenSellOrder(ordermode, DiffPips, lots, expire, shift);
     }

//---
//  Print(__FUNCTION__, ": Time=",iTime(NULL,0,shift), " ret=", ret);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OpenBuyOrder(int mode, int diffpips, double lots, datetime expire = 0, int shift = 0)
  {
   double sl = 0, tp = 0;
   bool ret = false;
   double price = 0;
   double   refprice = 0;
 
   switch(mode)
     {
      case OP_BUY:
         price = Ask();
         refprice = Bid();
         break;
      case OP_BUYSTOP:
         price = Ask() + diffpips * POINT;
         refprice = Bid() + diffpips * POINT;
         break;
      case OP_BUYLIMIT:
         price = Ask() - diffpips * POINT;
         refprice = Bid() - diffpips * POINT;
         break;
     }
   price = ND(price);
   refprice = ND(refprice);

 //  CalculateTPSL( mode,shift);
   CalculateTPSL(TakeProfit,StopLoss,Lots,iCRV,mode,shift,TakeProfitTicks,StopLossTicks);

   if(StopLossTicks > 0)
     {
      sl = refprice - NDTP(StopLossTicks * POINT);
     }
   else
      sl = 0;
   if(TakeProfitTicks > 0)
     {
      tp = price + NDTP(TakeProfitTicks * POINT);
     }
   else
      tp = 0;



   Print(__FUNCTION__, ": mode=", mode, " lots=", lots, " price=", price, " sl=", sl, " tp=", tp);
   int ticket = OrderSend(Symbol(), mode, lots, price, Slippage, sl, tp, Program, MagicNumber, expire, Blue);
   if(ticket < 0)
     {
     }
   else
     {
      //      ret = OrderModify(ticket, OrderOpenPrice(), sl, tp, 0, Blue);
      ret = true;
     }
   return ret;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OpenSellOrder(int mode, int diffpips, double lots, datetime expire = 0, int shift = 0)
  {
   double sl = 0, tp = 0;
   bool ret = false;
  // string EAName = MQLInfoString(MQL5_PROGRAM_NAME);
   double   price = 0;
   double   refprice = 0;
   double spread = MarketInfo(Symbol(), MODE_SPREAD);
   spread = Ask() - Bid();
   spread = 0;
 
   switch(mode)
     {
      case OP_SELL:
         price = Bid();
         refprice = Ask();
         break;
      case OP_SELLSTOP:
         price = Bid() - diffpips * POINT;
         refprice = Ask() - diffpips * POINT;
         break;
      case OP_SELLLIMIT:
         price = Bid() + diffpips * POINT;
         refprice = Ask() + diffpips * POINT;
         break;
     }
   price = ND(price);
   refprice = ND(refprice);

   //CalculateTPSL(mode,shift);
  CalculateTPSL(TakeProfit,StopLoss,Lots,iCRV,mode,shift,TakeProfitTicks,StopLossTicks);

   
   if(StopLossTicks > 0)
     {
      sl = refprice + NDTP(StopLossTicks * POINT);
     }
   else
      sl = 0;
   if(TakeProfitTicks > 0)
     {
      tp = price  - NDTP(TakeProfitTicks * POINT);
     }
   else
      tp = 0;


   Print(__FUNCTION__, ": mode=", mode, " lots=", lots, " price=", price, " sl=", sl, " tp=", tp);
   int ticket = OrderSend(Symbol(), mode, lots, price, Slippage, sl, tp, Program, MagicNumber, expire, Red);
   if(ticket < 0)
     {
     }
   else
     {
      //    ret = OrderModify(ticket, OrderOpenPrice(), sl, tp, 0, Blue);
      ret = true;
     }

   return ret;
  }



//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
bool CheckForClose(int shift)
  {

   bool ret = false;
   bool ok = false;
//  Print(__FUNCTION__);
  // UpdateOrderlist(MagicNumber);   // 1x bei jedem neuen Bar
   ret =CloseOrderSingle(shift);


   return ret;
  }

// EA HELPER Functions  ===============================================+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CloseOrderSingle(int shift)
  {
   bool ret = false;
   int i;
   int openbar = 0;
   bool close = false;
   int signal = 0;
   OrderMachine.UpdateLists(MagicNumber);
   
   

   for(i = 0; i < OrderMachine.BuyOrderCount(); i++)
     {
      signal = GetCloseSignal(shift, OP_BUY, OrderMachine.BuyOrders[i]);
      if(signal > 0)
        {
         ret = true;
         if(!OrderClose(OrderMachine.BuyOrders[i],  Bid(), Slippage, clrBlack))
           {
            Print(__FUNCTION__, ": OrderClose error ", GetLastError());
           }
        }
     }

   for(i = 0; i < OrderMachine.SellOrderCount(); i++)
     {
      signal = GetCloseSignal(shift, OP_SELL, OrderMachine.SellOrders[i]);
      if(signal > 0)
        {
         ret = true;
         if(!OrderClose(OrderMachine.SellOrders[i], Ask(), Slippage, clrBlack))
           {
            Print(__FUNCTION__, ": OrderClose error ", GetLastError());
           }
        }
     }
   return ret;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb, double lots, int type)
  {
   string oper = (type == OP_BUY) ? "Buy" : "Sell";

///double free_margin = AccountFreeMarginCheck(symb, type, lots);
///double free_money = AccountEquity() - free_margin;
   double marginRequired = lots ;  // *MarketInfo(Symbol(), MODE_MARGINREQUIRED);
   if (type==OP_BUY)
   {
      marginRequired *= SymbolInfoDouble(Symbol(),SYMBOL_MARGIN_LONG)  ;
   }
   else
   {
     marginRequired *= SymbolInfoDouble(Symbol(),SYMBOL_MARGIN_SHORT)  ;
   }
               
   double free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE); - marginRequired; //                  AccountFreeMarginCheck(symb,type,lots);
   double free_money = AccountInfoDouble(ACCOUNT_EQUITY) - marginRequired;
   double diff = AccountInfoDouble(ACCOUNT_BALANCE) -  AccountInfoDouble(ACCOUNT_EQUITY) ;

   Print(__FUNCTION__, " : free_margin=", free_margin, " free_money=", free_money, " diff=", diff, " lots=", lots);
   if(diff > 0)
     {
      if(TotalEquityRisk > 0)
        {
         if(diff > TotalEquityRisk / 100.0 * AccountInfoDouble(ACCOUNT_EQUITY))
           {
            Print(__FUNCTION__, ": To much losses to open new order for ", oper, " ", lots, " ", symb, " Risk=", TotalEquityRisk / 100.0 * AccountInfoDouble(ACCOUNT_EQUITY), "Diff=", diff);
            return(false);
           }
        }
     }

   if(free_margin <= 0 || free_money <= 0)
     {
      Print(__FUNCTION__, ": Not enough money for ", oper, " ", lots, " ", symb);
      return(false);

     }
//-- if there is not enough money
// else if(free_margin<0)
   int StopOutMode=AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
   double StopOutLevel=AccountInfoDouble(ACCOUNT_MARGIN_SO_SO);
   
   
   if((((StopOutMode == 1) &&
        (free_margin < StopOutLevel))
       || ((StopOutMode == 0) &&
           ((AccountInfoDouble(ACCOUNT_EQUITY) / (free_money) * 100) < StopOutLevel))))
     {
      Print(__FUNCTION__, ": StopOut level  Not enough money for ", oper, " ", lots, " ", symb);
      return(false);
     }
   else
      if(free_margin < 0)
        {
         Print(__FUNCTION__, ": Not enough money for ", oper, " ", lots, " ", symb);
         return(false);
        }
//--- checking successful
   return(true);
  }
  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NDTP(double val)
  {
   int  SPREAD = SymbolInfoInteger(Symbol(),SYMBOL_SPREAD);
   int StopLevel = SymbolInfoInteger(Symbol(),SYMBOL_TRADE_STOPS_LEVEL);
   if(val < StopLevel * POINT + SPREAD * POINT)
      val = StopLevel * POINT + SPREAD * POINT;
   return(NormalizeDouble(val, Digits()));
  }

//+------------------------------------------------------------------+
double ND(double val)
  {
   return(NormalizeDouble(val, Digits()));
  }
//+------------------------------------------------------------------+

