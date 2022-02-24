//+------------------------------------------------------------------+
//|                                               EABody.mqh |
//+------------------------------------------------------------------+

#include <cb\CB_Commons.mqh>
#include <cb\CB_OrderMachine.mqh>
//#include <cb\CB_SLTPCalculator.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern int Expert_OnInit(int barcount = 10);
extern int GetOpenSignal(int shift);
extern int GetCloseSignal(int shift, int mode,  int ticket);

enum ENUM_ORDER_CALC_MODE
  {
   BYPIPS = 0,
   BYPRICE = 1
  };

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
   ENUM_ORDER_TYPE   OrderMode ;
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
   //  int               TrailingStop;
   double            OpenPrice;
   int               magic;
   string            symbol;
   datetime          LastActionTime;

public:
   COrderMachine     *OrderMachine;



public:

                     CcbExpert(void);
                    ~CcbExpert(void);

   bool              CheckPreConditions();
   void              Trade();
   bool              CheckForOpen(int shift);
   // bool              OpenBuyOrder(int mode, double price, double lots, datetime expire = 0, int shift = 0);
   // bool              OpenSellOrder(int mode, double price, double lots, datetime expire = 0, int shift = 0);
   bool              OpenOrder(ENUM_ORDER_TYPE mode, double pendingprice, double lots, datetime expire = 0, int shift = 0);
   bool              OpenOrder(ENUM_ORDER_TYPE mode, double lots, double price, double slprice, double tpprice, datetime expire);
   bool              CheckForClose(int shift);
   bool              CloseOrderSingle(int shift);
   bool              CloseAllPositions(ENUM_POSITION_TYPE mode);

   void              SetMagicNumber(int no) {magic = no;}
   void              SetSymbol(string sym) {symbol = sym;}
   void              SetPendingOrderExpireBarCount(int no) {PendingOrderExpireBarCount = no;}
   void              SetLots(double no)  {Lots = no;}
   void              SetMaxBuyPositions(int no)  {MaxBuyPositions = no;}
   void              SetMaxSellPositions(int no) {MaxSellPositions = no;}
   void              SetMaxBuyOrders(int no)  {MaxBuyOrders = no;}
   void              SetMaxSellOrders(int no) {MaxSellOrders = no;}
   void              SetTotalEquityRisk(double no) { TotalEquityRisk = no;}
   void              SetEtheryTick(bool on) {EtheryTick = on;}
   //  void              SetTrailingStop(int val) {TrailingStop = val;}
   void              SetStopLossTicks(int val) {StopLossTicks = val;}
   void              SetTakeProfitTicks(int val) {TakeProfitTicks = val;}
   void              SetOrderValues(ENUM_ORDER_TYPE mode, double price, double SLPrice, double TPPrice);
   void              SetOrderValues(ENUM_ORDER_TYPE mode, double price, int sl, int tp);

   void              SetMaxSpread(int spread) { MaxSpread = spread;}
   void              SetStartShift(int shift) { START_SHIFT = shift;}
   void              SetOrderMode(ENUM_ORDER_TYPE   mode) {OrderMode = mode;}

   bool              OrderModify(int ticket, double price, double slp, double tpp, datetime new_expiration)
     {
      return OrderMachine.OrderModify(ticket, price, slp, tpp, new_expiration);
     }
   bool              OrderModify(int ticket, double price, int sl, int tp, datetime new_expiration)
     {
      return OrderMachine.OrderModify(ticket, price, sl, tp, new_expiration);
     }
   void              OrdersModify(ENUM_ORDER_TYPE type, double price, double sl_price, double tp_price, datetime new_expiration)
     {
      OrderMachine.OrdersModify(symbol, magic, type, price, sl_price, tp_price, new_expiration);
     }
   void              OrdersModify(ENUM_ORDER_TYPE type, double price,  int sl, int tp, datetime new_expiration)
     {
      OrderMachine.OrdersModify(symbol, magic, type, price, sl, tp, new_expiration);
     }
   void              PositionsModify(ENUM_POSITION_TYPE type, int sl, int tp)
     {
      OrderMachine.PositionsModify(symbol, magic, type, sl, tp);
     }
   void              PositionsModify(ENUM_POSITION_TYPE type, double sl_price, double tp_price)
     {
      OrderMachine.PositionsModify(symbol, magic, type, sl_price, tp_price);
     }
   void              SetTrailingStop(int tstop)
     {
      OrderMachine.PositionsSetStop(symbol, magic, tstop, 0);
     }
   void              SetCalcMode(ENUM_ORDER_CALC_MODE mode)
     {
      calc_mode = mode;
     }
   double            SetPoint()
     {
      int digits = (int)MarketInfo(symbol, MODE_DIGITS);
      double point = MarketInfo(symbol, MODE_POINT),
             pt = (digits == 5 || digits == 3) ? point * 10 : point;
      return(pt);
     }

protected:
   double            NDTP(double val);
   double            ND(double val);
   bool              CheckMoneyForTrade(string symb, double lots, int type);
   double            CheckVolumeValue(double checkedvol);
   datetime          ExpiredDate()
     {
      datetime expireDate = 0;
      if(OrderMode > ORDER_TYPE_SELL)
        {
         if(PendingOrderExpireBarCount > 0)
           {
            expireDate = TimeCurrent() +  PendingOrderExpireBarCount * PeriodSeconds(); // PendingOrderExpireHours*60*60  ;
            //    Print(__FUNCTION__,": ExpireDate=", expireDate);
           }
        }
      return expireDate;
     }
   ENUM_ORDER_CALC_MODE calc_mode;
   double            slprice;
   double            tpprice;
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CcbExpert::CcbExpert(void):
   START_SHIFT(1),
   EtheryTick(false),
   OrderMode(0),
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
//   TrailingStop(0),
   calc_mode(BYPIPS),
   slprice(0),
   tpprice(0)

  {
   POINT =    SetPoint();
   Program =  MQLInfoString(MQL_PROGRAM_NAME);
   symbol = Symbol();
   OrderMachine = new COrderMachine();
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
void CcbExpert::SetOrderValues(ENUM_ORDER_TYPE mode, double price, double SLPrice, double TPPrice)
  {
   calc_mode = BYPRICE;
   OrderMode = mode;
   slprice = SLPrice;
   tpprice = TPPrice;
   if(price > 0)
      OpenPrice = price;
  // Print(__FUNCTION__, " OrderMode=", OrderMode, " OpenPrice=", OpenPrice, " tpprice=", tpprice, " slprice=", slprice);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
void CcbExpert::SetOrderValues2(int signal, ENUM_ORDERMODES mode, double price, double SLPrice, double TPPrice)
  {
   Print(__FUNCTION__, " mode=", mode, " price=", price, " SLPrice=", SLPrice, " TPPrice=", TPPrice);
   OrderMode = mode;
   if(signal > 0)   // BUY
     {
      if(TPPrice > 0)
        {
         TakeProfitTicks = (TPPrice - price) / POINT;
         TakeProfitTicks = CheckTP(TakeProfitTicks);
        }
      else
         if(TPPrice < 0)
           {
            TakeProfitTicks = 0;
           }
      if(SLPrice > 0)
        {
         StopLossTicks = (price - SLPrice) / POINT;
         StopLossTicks = CheckSL(StopLossTicks);
        }
      else
         if(SLPrice < 0)
           {
            StopLossTicks = 0;
           }
     }
   else   //SELL
     {
      if(TPPrice > 0)
        {
         TakeProfitTicks = (price - TPPrice) / POINT;
         TakeProfitTicks = CheckTP(TakeProfitTicks);
        }
      else
         if(TPPrice < 0)
           {
            TakeProfitTicks = 0;
           }
      if(SLPrice > 0)
        {
         StopLossTicks = (SLPrice - price) / POINT;
         StopLossTicks = CheckSL(StopLossTicks);
        }
      else
         if(SLPrice < 0)
           {
            StopLossTicks = 0;
           }
     }
   if(price > 0)
      OpenPrice = price;
   Print(__FUNCTION__, " signal=", signal, " OrderMode=", OrderMode, " OpenPrice=", OpenPrice, " TakeProfitTicks=", TakeProfitTicks, " StopLossTicks=", StopLossTicks);
  }
  */
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CcbExpert::SetOrderValues(ENUM_ORDER_TYPE mode, double price, int slticks, int tpticks)
  {
   calc_mode = BYPIPS;
   OrderMode = mode;
   StopLossTicks = slticks;
   TakeProfitTicks = tpticks;
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
   if( Bars(_Symbol, _Period) < 100)
     {
      Print(__FUNCTION__," Bars less than 100");
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
      int curspread = (int)(MathAbs(Ask() - Bid()) / POINT);
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
  //    Print(__FUNCSIG__,": CHECKFORCLOSE___________________");
      changed = CheckForClose(shift);
      if(changed)
        {
         LastActionTime = iTime(NULL, 0, shift);
        }
      if(CheckPreConditions())
        {
   //     Print(__FUNCSIG__,": CheckPreConditions _________________________");  
         if(AccountBalanceBeforeLoss < AccountInfoDouble(ACCOUNT_BALANCE))
           {
            AccountBalanceBeforeLoss = AccountInfoDouble(ACCOUNT_BALANCE);
           }
    //     Print(__FUNCSIG__,": CHECKFOROPEN___________________");  
         changed = CheckForOpen(shift);
         if(changed)
           {
            LastActionTime = iTime(NULL, 0, shift);
           }
        }
      /*
      if(TrailingStop > 0)
      {
       //   Print(__FUNCTION__,": Set TrailingStop=",TrailingStop);
       OrderMachine.PositionsSetStop(symbol, magic, TrailingStop, 0);
      }
      */
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getDirection(ENUM_ORDER_TYPE mode)
  {
   switch(mode)
     {
      case ORDER_TYPE_BUY:
      case ORDER_TYPE_BUY_LIMIT:
      case ORDER_TYPE_BUY_STOP:
      case ORDER_TYPE_BUY_STOP_LIMIT:
         return 1;
      case ORDER_TYPE_SELL:
      case ORDER_TYPE_SELL_LIMIT:
      case ORDER_TYPE_SELL_STOP:
      case ORDER_TYPE_SELL_STOP_LIMIT:
         return -11;
     }
   return 0;
  }
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
bool CcbExpert::CheckForOpen(int shift)
  {
//  ENUM_ORDER_TYPE ordermode = 0;
   bool ret = false;
   double lots = 0;
   OrderMachine.UpdateLists(magic);   // 1x bei jedem neuen Bar
   int signal = GetOpenSignal(shift);
   if (signal != 0)   signal = getDirection(OrderMode);
   if (signal != 0)  Print(__FUNCTION__," !!!!!!!!! Signal=",signal);
   if(signal == 0)
      return false;
// lots = LotsOptimized(LotsIncreaseFactor, LotsRisk);
   lots = CheckVolumeValue(Lots);
   datetime expire = ExpiredDate();
   bool doit = false;
// signal=1;
//--- buy order
   if(signal > 0)   //&& ((OrderMachine.BuyOrderCount() < MaxBuyPositions && (OrderCnt < MaxOrdersTotal || MaxOrdersTotal == 0)) ||  OrderMode != MODE_MARKET))
      //   if(signal>0 && ((BuyOrderCount<MaxBuyPositions && !OneOrderAtTime) || (OrderCnt == 0 && OneOrderAtTime)))
     {
      if(CheckMoneyForTrade(symbol, lots, OP_BUY) == false)
         return false;
      Print(__FUNCTION__, ": ***** BUY: BuyPositionCount=", OrderMachine.BuyPositionCount(), ": BuyOrderCount=", OrderMachine.BuyOrderCount(), " MaxBuyPositions=", MaxBuyPositions, " MaxBuyOrders=", MaxBuyOrders);
     }
   if(signal < 0)
     {
      if(CheckMoneyForTrade(symbol, lots, OP_SELL) == false)
         return false;
      Print(__FUNCTION__, ": **** SELL: SellPositionCount=", OrderMachine.SellPositionCount(), ": SellOrderCount=", OrderMachine.SellOrderCount(), " MaxSellPositions=", MaxSellPositions, " MaxSellOrders=", MaxSellOrders);
     }
   switch(OrderMode)
     {
      case ORDER_TYPE_BUY:
         doit = OrderMachine.BuyPositionCount() < MaxBuyPositions;
         break;
      case ORDER_TYPE_BUY_STOP:
         doit = OrderMachine.BuyOrderCount() < MaxBuyOrders;
         break;
      case ORDER_TYPE_BUY_LIMIT:
         doit = OrderMachine.BuyOrderCount() < MaxBuyOrders;
      case ORDER_TYPE_SELL:
         doit = OrderMachine.SellPositionCount() < MaxSellPositions;
         break;
      case ORDER_TYPE_SELL_STOP:
         doit = OrderMachine.SellOrderCount() < MaxSellOrders;
         break;
      case ORDER_TYPE_SELL_LIMIT:
         doit = OrderMachine.SellOrderCount() < MaxSellOrders;
         break;
     }
   if(doit)
     {
      ret = OpenOrder(OrderMode, OpenPrice, lots, expire, shift);
     }
//---
//  Print(__FUNCTION__, ": Time=",iTime(NULL,0,shift), " ret=", ret);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CcbExpert::OpenOrder(ENUM_ORDER_TYPE mode, double pendingprice, double lots, datetime expire = 0, int shift = 0)
  {
   double sl = 0, tp = 0;
   bool ret = false;
   double price = 0;
   double   refprice = 0;
   double   spread = Ask() - Bid();
   spread = 0;
   switch(mode)
     {
      case OP_BUY:
         price = Ask();
         refprice = Bid();
         break;
      case OP_BUYSTOP:
      case OP_BUYLIMIT:
         price = pendingprice;  //Ask() + diffpips * POINT;
         refprice = pendingprice + spread;// Bid() + diffpips * POINT;
         break;
      case OP_SELL:
         price = Bid();
         refprice = Ask();
         break;
      case OP_SELLSTOP:
      case OP_SELLLIMIT:
         price = pendingprice; //  Bid() - diffpips * POINT;
         refprice = pendingprice - spread;  // Ask() - diffpips * POINT;
         break;
     }
   price = ND(price);
   refprice = ND(refprice);
   if(calc_mode == BYPIPS)
     {
      switch(mode)
        {
         case OP_BUY:
         case OP_BUYSTOP:
         case OP_BUYLIMIT:
           {
            if(StopLossTicks > 0)
              {
               sl = refprice - NDTP(StopLossTicks * POINT);
              }
            if(TakeProfitTicks > 0)
              {
               tp = price + NDTP(TakeProfitTicks * POINT);
              }
           }
         break;
         case OP_SELL:
         case OP_SELLSTOP:
         case OP_SELLLIMIT:
           {
            if(StopLossTicks > 0)
              {
               sl = refprice + NDTP(StopLossTicks * POINT);
              }
            if(TakeProfitTicks > 0)
              {
               tp = price  - NDTP(TakeProfitTicks * POINT);
              }
           }
         break;
        }
     }
   else
     {
      tp = tpprice;
      sl = slprice;
     }
  // Print(__FUNCTION__, ": cacl_mode=", calc_mode, " mode=", mode, " lots=", lots, " price=", price, " sl=", sl, " tp=", tp, " expire=", expire);
   ret = OpenOrder(mode, lots, price, sl, tp, expire);
   return ret;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CcbExpert::OpenOrder(ENUM_ORDER_TYPE mode, double lots, double price, double sl_price, double tp_price, datetime expire)
  {
   Print(__FUNCTION__, ": mode=", mode, " lots=", lots, " price=", price, " slprice=", sl_price, " tpprice=", tp_price, " expire=", expire);
   price = CheckOpenPrice(price, mode);
   int ticket = OrderMachine.OrderSend(symbol, mode, lots, price, Slippage, sl_price, tp_price, Program, magic, expire);
   bool ret = ticket > 0;
   return ret;
  }
/*
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
 Print(__FUNCTION__, ": mode=", mode, " lots=", lots, " price=", price, " sl=", sl, " tp=", tp, " expire=", expire);
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
*/
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
         if(!OrderMachine.PositionClose(OrderMachine.BuyPositions[i]))
           {
            Print(__FUNCTION__, ": OrderClose error ", GetLastError());
           }
        }
     }
    OrderMachine.UpdateLists(magic);  
   for(i = 0; i < OrderMachine.SellPositionCount(); i++)
     {
      signal = GetCloseSignal(shift, OP_SELL, OrderMachine.SellPositions[i]);
      if(signal > 0)
        {
         ret = true;
         if(!OrderMachine.PositionClose(OrderMachine.SellPositions[i]))
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
bool CcbExpert::CloseAllPositions(ENUM_POSITION_TYPE type)
  {
   bool ret = false;
   int i;
   int openbar = 0;
   bool close = false;
   int signal = 0;
   OrderMachine.UpdateLists(magic);
   if(type == POSITION_TYPE_BUY)
     {
      for(i = 0; i < OrderMachine.BuyPositionCount(); i++)
        {
         ret = true;
         if(!OrderMachine.PositionClose(OrderMachine.BuyPositions[i]))
           {
            Print(__FUNCTION__, ": OrderClose error ", GetLastError());
           }
        }
     }
   if(type == POSITION_TYPE_SELL)
     {
      for(i = 0; i < OrderMachine.SellPositionCount(); i++)
        {
         ret = true;
         if(!OrderMachine.PositionClose(OrderMachine.SellPositions[i]))
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
      marginRequired *= SymbolInfoDouble(symbol, SYMBOL_MARGIN_LONG)  ;
     }
   else
     {
      marginRequired *= SymbolInfoDouble(symbol, SYMBOL_MARGIN_SHORT)  ;
     }
   double free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE) ;
   double free_money = AccountInfoDouble(ACCOUNT_EQUITY) - marginRequired;
   double diff = AccountInfoDouble(ACCOUNT_BALANCE) -  AccountInfoDouble(ACCOUNT_EQUITY) ;
  // Print(__FUNCTION__, " : free_margin=", free_margin, " free_money=", free_money, " diff=", diff, " lots=", lots);
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
   long StopOutMode = AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE);
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
double CcbExpert::CheckVolumeValue(double checkedvol)
  {
//--- minimal allowed volume for trade operations
   double min_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   if(checkedvol < min_volume)
      return(min_volume);
//--- maximal allowed volume of trade operations
   double max_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(checkedvol > max_volume)
      return(max_volume);
//--- get minimal step of volume changing
   double volume_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   int ratio = (int)MathRound(checkedvol / volume_step);
   if(MathAbs(ratio * volume_step - checkedvol) > 0.0000001)
      return(ratio * volume_step);
   return(checkedvol);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CcbExpert::NDTP(double val)
  {
   long  SPREAD = SymbolInfoInteger(symbol, SYMBOL_SPREAD);
   long StopLevel = SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
   if(val < (double)(StopLevel * POINT + SPREAD * POINT))
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

//+------------------------------------------------------------------+
