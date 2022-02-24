//+------------------------------------------------------------------+
//|                                               EABody.mqh |
//+------------------------------------------------------------------+

#include <cb\CB_Commons.mqh>
#include <cb\CB_OrderChangers.mqh>
//#include <cb\CB_SLTPCalculator.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern int Expert_OnInit(int barcount = 10);
extern int GetOpenSignal(int shift);
extern int GetCloseSignal(int shift, int mode,  int ticket);


//+------------------------------------------------------------------+
//| Class CHull.                                                      |
//| Purpose: Class of the "Moving Average" indicator.                |
//|          Derives from class CIndicator.                          |
//+------------------------------------------------------------------+
class CcbExpert
  {

protected:

   int               START_SHIFT ;
   bool              EtheryTick;
   ENUM_ORDERMODES   OrderMode ;
   int               PendingOrderExpireBarCount;
   double            Lots ;

   int               MaxBuyPositions ;
   int               MaxSellPositions ;
   int               MaxBuyOrders ;
   int               MaxSellOrders ;

   double            TotalEquityRisk ;    //Total Equity Risk
   //input  bool             OneOrderAtTime = false;
   //int               MinOrderBarDiff = 0;

   int               MaxSpread ;
   int               Slippage      ;

   double AccountBalanceBeforeLoss ;

   datetime          lastTradeTime ;
   bool              changed ;
   double            POINT ;
   string Program ;


   int               StopLossTicks;
   int               TakeProfitTicks;
   int               TrailingStop;
   double            OpenPrice;
   int               magic;
   datetime          LastActionTime;



public:

                     CcbExpert(void);
                    ~CcbExpert(void);

   bool              CheckPreConditions();
   void              Trade();
   bool              CheckForOpen(int shift);
   bool              OpenBuyOrder(int mode, double price, double lots, datetime expire = 0, int shift = 0);
   bool              OpenSellOrder(int mode, double price, double lots, datetime expire = 0, int shift = 0);
   bool              CheckForClose(int shift);
   bool              CloseOrderSingle(int shift);

   void              SetMagicNumber(int no) {magic = no;}
   void              SetPendingOrderExpireBarCount(int no) {PendingOrderExpireBarCount = no;}
   void              SetLots(double no)  {Lots = no;}
   void              SetMaxBuyPositions(int no)  {MaxBuyPositions = no;}
   void              SetMaxSellPositions(int no) {MaxSellPositions = no;}
   void              SetMaxBuyOrders(int no)  {MaxBuyOrders = no;}
   void              SetMaxSellOrders(int no) {MaxSellOrders = no;}
   void              SetTotalEquityRisk(double no) { TotalEquityRisk = no;}
   void              SetEtheryTick(bool on) {EtheryTick = on;}
   void              SetTrailingStop(int val) {TrailingStop = val;}
   void              SetStopLossTicks(int val) {StopLossTicks = val;}
   void              SetTakeProfitTicks(int val) {TakeProfitTicks = val;}
   void              SetOrderValues(ENUM_ORDERMODES mode, double price, double SLPrice, double TPPrice);

   void              SetMaxSpread(int spread) { MaxSpread = spread;}
   void              SetStartShift(int shift) { START_SHIFT = shift;}
   void              SetOrderMode(ENUM_ORDERMODES   mode) {OrderMode = mode;}

   bool              OrderModify(int ticket, double price, double slp, double tpp, datetime new_expiration)
     {
      return OrderMachine.OrderModify(ticket, price, slp, tpp, new_expiration);
     }
   bool              OrderModify(int ticket, double price, int sl, int tp, datetime new_expiration)
     {
      return OrderMachine.OrderModify(ticket, price, sl, tp, new_expiration);
     }

protected:
   double            NDTP(double val);
   double            ND(double val);
   bool              CheckMoneyForTrade(string symb, double lots, int type);
   datetime          ExpiredDate()
     {
      datetime expireDate = 0;
      if(OrderMode != MODE_MARKET)
        {
         if(PendingOrderExpireBarCount > 0)
           {
            expireDate = TimeCurrent() +  PendingOrderExpireBarCount * PeriodSeconds(); // PendingOrderExpireHours*60*60  ;
            //    Print(__FUNCTION__,": ExpireDate=", expireDate);
           }
        }
      return expireDate;
     }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CcbExpert::CcbExpert(void):
   START_SHIFT(1),
   EtheryTick(false),
   OrderMode(MODE_MARKET),
   PendingOrderExpireBarCount(5),
   Lots(0.1),
   MaxBuyPositions(10),
   MaxSellPositions(10),
   MaxBuyOrders(10),
   MaxSellOrders(10),

   TotalEquityRisk(10),
   MaxSpread(10),
   Slippage(10),
   AccountBalanceBeforeLoss(0),
   lastTradeTime(0),
   changed(false),
   StopLossTicks(10),
   TakeProfitTicks(10),
   OpenPrice(0),
   magic(0),
   LastActionTime(0),
   TrailingStop(0)

  {
   POINT =    Point();
   Program =  MQLInfoString(MQL_PROGRAM_NAME);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CcbExpert::~CcbExpert(void)
  {
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CcbExpert::SetOrderValues(ENUM_ORDERMODES mode, double price, double SLPrice, double TPPrice)
  {
   Print(__FUNCTION__, " mode=", mode, " price=", price, " SLPrice=", SLPrice, " TPPrice=", TPPrice);
   OrderMode = mode;
   if(TPPrice > 0)
     {
      TakeProfitTicks = MathAbs(price - TPPrice) / Point();
      TakeProfitTicks = CheckTP(TakeProfitTicks);
     }
   else
      if(TPPrice < 0)
        {
         TakeProfitTicks = 0;
        }
   if(SLPrice > 0)
     {
      StopLossTicks = MathAbs(price - SLPrice) / Point();
      StopLossTicks = CheckSL(StopLossTicks);
     }
   else
      if(SLPrice < 0)
        {
         StopLossTicks = 0;
        }
   if(price > 0)
      OpenPrice = price;
   Print(__FUNCTION__, " OrderMode=", OrderMode, " OpenPrice=", OpenPrice, " TakeProfitTicks=", TakeProfitTicks, " StopLossTicks=", StopLossTicks);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CcbExpert::CheckPreConditions()
  {
   string msg = "";
//  if(IsTesting() || IsOptimization() || DEBUGMODE)
//     return ret;
#ifdef TESTING
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CcbExpert::Trade()
  {
   bool isnewbar = false;
   int shift = START_SHIFT;
   if(lastTradeTime < iTime(NULL, 0, shift) || (EtheryTick && iTime(NULL, 0, shift) > LastActionTime))
     {
      lastTradeTime = iTime(NULL, 0, shift);
      isnewbar = true;
      changed = false;
     }
#ifdef TESTING
   isnewbar = true;
   changed = false;
#endif
   if(isnewbar)
     {
      changed = CheckForClose(shift);
      if(changed)
        {
         LastActionTime = iTime(NULL, 0, shift);
        }
      if(CheckPreConditions())
        {
         if(AccountBalanceBeforeLoss < AccountInfoDouble(ACCOUNT_BALANCE))
           {
            AccountBalanceBeforeLoss = AccountInfoDouble(ACCOUNT_BALANCE);
           }
         changed = CheckForOpen(shift);
         if(changed)
           {
            LastActionTime = iTime(NULL, 0, shift);
           }
        }
      if(TrailingStop > 0)
        {
         //   Print(__FUNCTION__,": Set TrailingStop=",TrailingStop);
         PositionsSetStop(magic, TrailingStop);
        }
     }
  }

//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
bool CcbExpert::CheckForOpen(int shift)
  {
   int    res;
   int ordermode = 0;
   bool ret = false;
   double lots = 0;
   OrderMachine.UpdateLists(magic);   // 1x bei jedem neuen Bar
   int signal = GetOpenSignal(shift);
// lots = LotsOptimized(LotsIncreaseFactor, LotsRisk);
   lots = Lots;
   datetime expire = ExpiredDate();
   bool doit = false;
// signal=1;
//--- buy order
   if(signal > 0)   //&& ((OrderMachine.BuyOrderCount() < MaxBuyPositions && (OrderCnt < MaxOrdersTotal || MaxOrdersTotal == 0)) ||  OrderMode != MODE_MARKET))
      //   if(signal>0 && ((BuyOrderCount<MaxBuyPositions && !OneOrderAtTime) || (OrderCnt == 0 && OneOrderAtTime)))
     {
      Print(__FUNCTION__, " Try OPEN BUY OpenPrice=", OpenPrice, " TakeProfitTicks=", TakeProfitTicks, " StopLossTicks=", StopLossTicks, " Time=", TimeAsString(shift));
      if(CheckMoneyForTrade(Symbol(), lots, OP_BUY) == false)
         return false;
      Print(__FUNCTION__, ": ***** BUY: SellOrderCount=", OrderMachine.SellOrderCount(), ": BuyOrderCount=", OrderMachine.BuyOrderCount());
      switch(OrderMode)
        {
         case MODE_MARKET:
            ordermode = OP_BUY;
            doit = OrderMachine.BuyPositionCount() < MaxBuyPositions;
            break;
         case MODE_STOP:
            ordermode = OP_BUYSTOP;
            doit = OrderMachine.BuyOrderCount() < MaxBuyOrders;
            break;
         case MODE_LIMIT:
            ordermode = OP_BUYLIMIT;
            doit = OrderMachine.BuyOrderCount() < MaxBuyOrders;
            break;
        }
      if(doit)
        {
         ret = OpenBuyOrder(ordermode, OpenPrice, lots, expire, shift);
        }
     }
//--- sell order
   if(signal < 0)  // && ((OrderMachine.SellOrderCount() < MaxSellPositions  && (OrderCnt < MaxOrdersTotal || MaxOrdersTotal == 0)) ||  OrderMode != MODE_MARKET))
     {
      Print(__FUNCTION__, " Try OPEN SELL OpenPrice=", OpenPrice, " TakeProfitTicks=", TakeProfitTicks, " StopLossTicks=", StopLossTicks, " Time=", TimeAsString(shift));
      if(CheckMoneyForTrade(Symbol(), lots, OP_SELL) == false)
         return false;
      Print(__FUNCTION__, ": **** SELL: SellOrderCount=", OrderMachine.SellOrderCount(), ": BuyOrderCount=", OrderMachine.BuyOrderCount());
      switch(OrderMode)
        {
         case MODE_MARKET:
            ordermode = OP_SELL;
            doit = OrderMachine.SellPositionCount() < MaxSellPositions;
            break;
         case MODE_STOP:
            ordermode = OP_SELLSTOP;
            doit = OrderMachine.SellPositionCount() < MaxSellPositions;
            break;
         case MODE_LIMIT:
            ordermode = OP_SELLLIMIT;
            doit = OrderMachine.SellPositionCount() < MaxSellPositions;
            break;
        }
      if(doit)
        {
         ret = OpenSellOrder(ordermode, OpenPrice, lots, expire, shift);
        }
     }
//---
//  Print(__FUNCTION__, ": Time=",iTime(NULL,0,shift), " ret=", ret);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CcbExpert::OpenBuyOrder(int mode, double pendingprice, double lots, datetime expire = 0, int shift = 0)
  {
   double sl = 0, tp = 0;
   bool ret = false;
   double price = 0;
   double   refprice = 0;
   double   spread = Ask() - Bid();
   switch(mode)
     {
      case OP_BUY:
         price = Ask();
         refprice = Bid();
         break;
      case OP_BUYSTOP:
         price = pendingprice;  //Ask() + diffpips * POINT;
         refprice = pendingprice + spread;// Bid() + diffpips * POINT;
         break;
      case OP_BUYLIMIT:
         price = pendingprice;  //Ask() - diffpips * POINT;
         refprice = pendingprice + spread;// Bid() - diffpips * POINT;
         break;
     }
   price = ND(price);
   refprice = ND(refprice);
//  CalculateTPSL( mode,shift);
//   CalculateTPSL(TakeProfit, StopLoss, Lots, iCRV, mode, shift, TakeProfitTicks, StopLossTicks);
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
   Print(__FUNCTION__, ": mode=", mode, " lots=", lots, " price=", price, " sl=", sl, " tp=", tp," expire=",expire);
   int ticket = OrderMachine.OrderSend(Symbol(), mode, lots, price, Slippage, sl, tp, Program, magic, expire);
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
bool CcbExpert::OpenSellOrder(int mode, double pendingprice, double lots, datetime expire = 0, int shift = 0)
  {
   double sl = 0, tp = 0;
   bool ret = false;
// string EAName = MQLInfoString(MQL5_PROGRAM_NAME);
   double   price = 0;
   double   refprice = 0;
   double   spread = Ask() - Bid();
   switch(mode)
     {
      case OP_SELL:
         price = Bid();
         refprice = Ask();
         break;
      case OP_SELLSTOP:
         price = pendingprice; //  Bid() - diffpips * POINT;
         refprice = pendingprice - spread;  // Ask() - diffpips * POINT;
         break;
      case OP_SELLLIMIT:
         price = pendingprice; // Bid() + diffpips * POINT;
         refprice = pendingprice - spread; // Ask() + diffpips * POINT;
         break;
     }
   price = ND(price);
   refprice = ND(refprice);
//CalculateTPSL(mode,shift);
//  CalculateTPSL(TakeProfit, StopLoss, Lots, iCRV, mode, shift, TakeProfitTicks, StopLossTicks);
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
   Print(__FUNCTION__, ": mode=", mode, " lots=", lots, " price=", price, " sl=", sl, " tp=", tp," expire=",expire);
   int ticket = OrderMachine.OrderSend(Symbol(), mode, lots, price, Slippage, sl, tp, Program, magic, expire);
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
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
bool CcbExpert::CheckForClose(int shift)
  {
   bool ret = false;
   bool ok = false;
//  Print(__FUNCTION__);
// UpdateOrderlist(magic);   // 1x bei jedem neuen Bar
   ret = CloseOrderSingle(shift);
   return ret;
  }

// EA HELPER Functions  ===============================================+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CcbExpert::CloseOrderSingle(int shift)
  {
   bool ret = false;
   int i;
   int openbar = 0;
   bool close = false;
   int signal = 0;
   OrderMachine.UpdateLists(magic);
   for(i = 0; i < OrderMachine.BuyPositionCount(); i++)
     {
      signal = GetCloseSignal(shift, OP_BUY, OrderMachine.BuyPositions[i]);
      if(signal > 0)
        {
         ret = true;
         if(!PositionClose(OrderMachine.BuyOrders[i]))
           {
            Print(__FUNCTION__, ": OrderClose error ", GetLastError());
           }
        }
     }
   for(i = 0; i < OrderMachine.SellPositionCount(); i++)
     {
      signal = GetCloseSignal(shift, OP_SELL, OrderMachine.SellPositions[i]);
      if(signal > 0)
        {
         ret = true;
         if(!PositionClose(OrderMachine.SellPositions[i]))
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
bool CcbExpert::CheckMoneyForTrade(string symb, double lots, int type)
  {
   string oper = (type == OP_BUY) ? "Buy" : "Sell";
///double free_margin = AccountFreeMarginCheck(symb, type, lots);
///double free_money = AccountEquity() - free_margin;
   double marginRequired = lots ;  // *MarketInfo(Symbol(), MODE_MARGINREQUIRED);
   if(type == OP_BUY)
     {
      marginRequired *= SymbolInfoDouble(Symbol(), SYMBOL_MARGIN_LONG)  ;
     }
   else
     {
      marginRequired *= SymbolInfoDouble(Symbol(), SYMBOL_MARGIN_SHORT)  ;
     }
   double free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   - marginRequired; //                  AccountFreeMarginCheck(symb,type,lots);
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
   int StopOutMode = AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
   double StopOutLevel = AccountInfoDouble(ACCOUNT_MARGIN_SO_SO);
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
double CcbExpert::NDTP(double val)
  {
   int  SPREAD = SymbolInfoInteger(Symbol(), SYMBOL_SPREAD);
   int StopLevel = SymbolInfoInteger(Symbol(), SYMBOL_TRADE_STOPS_LEVEL);
   if(val < StopLevel * POINT + SPREAD * POINT)
      val = StopLevel * POINT + SPREAD * POINT;
   return(NormalizeDouble(val, Digits()));
  }

//+------------------------------------------------------------------+
double CcbExpert::ND(double val)
  {
   return(NormalizeDouble(val, Digits()));
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
