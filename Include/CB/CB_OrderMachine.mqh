//+------------------------------------------------------------------+
//|                                            CB_OrderFunctions.mqh |
//|                                                   Christof Blank |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Christof Blank"

#property strict
// #include <cb\stderror.mqh>
#include <cb\ErrorMsg.mqh>
#include <cb\CB_Pips&Lots.mqh>
//#include <debug_inc.mqh>
//--- declaration of constants
/*enum ENUM_ORDERMODES
  {
   MODE_MARKET = 0,
   MODE_LIMIT = 1,
   MODE_STOP = 2

  };
  */
//+------------------------------------------------------------------+

#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\AccountInfo.mqh>
/*
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo      m_account;                    // account info wrapper
*/
//+------------------------------------------------------------------+
//| COrderMachine expert class                                         |
//+------------------------------------------------------------------+
class COrderMachine
  {
protected:
   double            m_adjusted_point;             // point value adjusted for 3 or 5 points
   int               buyPostitionCount;
   int               sellPositionCount;
   int               buyOrderCount;
   int               sellOrderCount;


public:
                     COrderMachine(void);
                    ~COrderMachine(void);

   CTrade            m_trade;                      // trading object
   CSymbolInfo       m_symbol;                     // symbol info object
   CPositionInfo     m_position;                   // trade position object
   CAccountInfo      m_account;                    // account info wrapper
   COrderInfo        m_order;                      // order object

   int               BuyPositions[];
   int               SellPositions[];
   int               BuyOrders[];
   int               SellOrders[];


   bool              Init(void);
   bool              IsInitialized;
   void              Deinit(void);
   int               OrderSend(string   symbol,               // symbol
                               int      cmd,                 // operation
                               double   volume,              // volume
                               double   price,               // price
                               int      slippage,            // slippage
                               double   stoploss,            // stop loss
                               double   takeprofit,          // take profit
                               string   comment,        // comment
                               int      magic,             // magic number
                               datetime expiration);        // pending order expiration

   bool              PositionModify(int ticket, double stoploss, double takeprofit);
   bool              PositionModify(int ticket, int sl, int tp);
   bool              PositionClose(int  ticket);
   double            PositionProfit(int ticket);
   double            PositionOpenPrice(int ticket);
   double            PositionTakeProfit(int ticket);
   double            PositionStopLoss(int ticket);
   datetime          PositionOpenTime(int ticket);
   ENUM_POSITION_TYPE PositionType(int ticket);
   bool              PositionSetStop(int ticket, int trailingstop, int minwinticks);
   bool              PositionSetStop(int ticket, int trailingstop);
   bool              PositionSetTPSL(int tiket, int sl, int tp);

   void              UpdateLists(int magic);
   int               BuyPositionCount(void) const {return buyPostitionCount;}
   int               SellPositionCount(void)  const {return sellPositionCount;}
   int               BuyOrderCount(void)  const {return buyOrderCount;}
   int               SellOrderCount(void) const {return sellOrderCount;}

   bool              OrderModify(int ticket, double price, double slp, double tpp, datetime new_expiration);
   bool              OrderModify(int ticket, double price, int sl, int tp, datetime new_expiration);

   //--------------------------------------------------------------------------------
   void              OrdersModify(string symbol, int magic, ENUM_ORDER_TYPE type, double price, int sl, int tp, datetime new_expiration)
     {
      int total = OrdersTotal();
      int ticket = 0;
      int cnt = 0;
      Print(__FUNCTION__, " total=", total);
      for(cnt = 0; cnt < total; cnt++)
        {
         if((ticket = (int) OrderGetTicket(cnt)) > 0)
           {
            string o_symbol  =   OrderGetString(ORDER_SYMBOL);
            int o_magic   = (int)  OrderGetInteger(ORDER_MAGIC);
            ENUM_ORDER_TYPE o_type    = (ENUM_ORDER_TYPE)  OrderGetInteger(ORDER_TYPE);
            if((o_symbol == symbol || symbol == "") && // check for symbol
               o_type == type &&
               o_magic == magic) // check for magic
              {
               OrderModify(ticket, price, sl, tp, new_expiration);
              }
           }
        }
     }
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   void              OrdersModify(string symbol, int magic, ENUM_ORDER_TYPE type, double price, double slprice, double tprice, datetime new_expiration)
     {
      int total = OrdersTotal();
      int ticket = 0;
      int cnt = 0;
      Print(__FUNCTION__, " total=", total);
      for(cnt = 0; cnt < total; cnt++)
        {
         if((ticket = (int) OrderGetTicket(cnt)) > 0)
           {
            string o_symbol  =   OrderGetString(ORDER_SYMBOL);
            int o_magic   = (int) OrderGetInteger(ORDER_MAGIC);
            ENUM_ORDER_TYPE o_type    = (ENUM_ORDER_TYPE)  OrderGetInteger(ORDER_TYPE);
            if((o_symbol == symbol || symbol == "") && // check for symbol
               o_type == type &&
               o_magic == magic) // check for magic
              {
               OrderModify(ticket, price, slprice, tprice, new_expiration);
              }
           }
        }
     }
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
   void              PositionsSetStop(string symbol, int magic, int stoploss, int minwin)
     {
      int total = PositionsTotal();
      int ticket = 0;
      int cnt = 0;
      Print(__FUNCTION__, " total=", total);
      for(cnt = 0; cnt < total; cnt++)
        {
         if((ticket = (int) PositionGetTicket(cnt)) > 0)
           {
            string o_symbol  =   PositionGetString(POSITION_SYMBOL);
            int o_magic   = (int) PositionGetInteger(POSITION_MAGIC);
            if((o_symbol == symbol || symbol == "") && // check for symbol
               o_magic == magic) // check for magic
              {
               PositionSetStop(ticket, stoploss, minwin);
              }
           }
        }
     }

   void              PositionsModify(string symbol, int magic, ENUM_POSITION_TYPE type, double stoploss, double takeprofit)
     {
      int total = PositionsTotal();
      int ticket = 0;
      int cnt = 0;
      Print(__FUNCTION__, " total=", total);
      for(cnt = 0; cnt < total; cnt++)
        {
         if((ticket = (int) PositionGetTicket(cnt)) > 0)
           {
            string o_symbol  =   PositionGetString(POSITION_SYMBOL);
            int o_magic   = (int) PositionGetInteger(POSITION_MAGIC);
            ENUM_POSITION_TYPE o_type    = (ENUM_POSITION_TYPE) PositionGetInteger(POSITION_TYPE);
            if((o_symbol == symbol || symbol == "") && // check for symbol
               o_type == type &&
               o_magic == magic) // check for magic
              {
               PositionModify(ticket, stoploss, takeprofit);
              }
           }
        }
     }
   void              PositionsModify(string symbol, int magic, ENUM_POSITION_TYPE type, int stoploss, int takeprofit)
     {
      int total = PositionsTotal();
      int ticket = 0;
      int cnt = 0;
      Print(__FUNCTION__, " total=", total);
      for(cnt = 0; cnt < total; cnt++)
        {
         if((ticket = (int) PositionGetTicket(cnt)) > 0)
           {
            string o_symbol  =   PositionGetString(POSITION_SYMBOL);
            int o_magic   = (int)   OrderGetInteger(ORDER_MAGIC);
            ENUM_POSITION_TYPE o_type    = (ENUM_POSITION_TYPE)  OrderGetInteger(ORDER_TYPE);
            if((o_symbol == symbol || symbol == "") && // check for symbol
               o_type == type &&
               o_magic == magic) // check for magic
              {
               PositionModify(ticket, stoploss, takeprofit);
              }
           }
        }
     }
   //+------------------------------------------------------------------+
   //| Refreshes the symbol quotes data                                 |
   //+------------------------------------------------------------------+
   bool              RefreshRates(void)
     {
      //--- refresh rates
      if(!m_symbol.RefreshRates())
        {
         Print("RefreshRates error");
         return(false);
        }
      //--- protection against the return value of "zero"
      if(m_symbol.Ask() == 0 || m_symbol.Bid() == 0)
         return(false);
      //---
      return(true);
     }
   //--------------------------------------------------------------------------------
protected:
   bool              InitCheckParameters(const int digits_adjust);
   int               AddToList(int item, int &list[]);

   int               PositionTicketCount(int magic);
   int               PositionTickets(int& list[]);
   int               OrderTickets(int& list[]);

  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
COrderMachine::COrderMachine(void)
  {
   IsInitialized = false;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
COrderMachine::~COrderMachine(void)
  {
  }


//+------------------------------------------------------------------+
//| Initialization and checking for input parameters                 |
//+------------------------------------------------------------------+
bool COrderMachine::Init(void)
  {
//--- initialize common information
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(Symbol());
//--- tuning for 3 or 5 digits
   int digits_adjust = 1;
   if(m_symbol.Digits() == 3 || m_symbol.Digits() == 5)
      digits_adjust = 10;
   m_adjusted_point = m_symbol.Point() * digits_adjust;
//--- set default deviation for trading in adjusted points
   m_trade.SetDeviationInPoints(3 * digits_adjust);
//---
//--- succeed
   IsInitialized = true;
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COrderMachine::Deinit(void)
  {
   IsInitialized = false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int COrderMachine::AddToList(int item, int& list[])
  {
   int len = ArraySize(list);
   ArrayResize(list, len + 1);
   list[len] = item;
   return len + 1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COrderMachine:: UpdateLists(int magic)
  {
   int ticket = 0;
   buyPostitionCount = 0;
   sellPositionCount = 0;
   buyOrderCount = 0;
   sellOrderCount = 0;
   ArrayResize(BuyPositions, 0);
   ArrayResize(SellPositions, 0);
   ArrayResize(BuyOrders, 0);
   ArrayResize(SellOrders, 0);
   int cnt = PositionsTotal();
   for(int t = 0; t < cnt; t++)
     {
      ticket = (int) PositionGetTicket(t);
      if((ticket) > 0)
        {
         ENUM_POSITION_TYPE  type          = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         int o_magic = (int)  PositionGetInteger(POSITION_MAGIC);
         //  Print(__FUNCTION__,__DATETIME__, ": cnt=", cnt, " t=",t, " type=",type," magic=",magic," omagic=",o_magic," ticket=",ticket," BuyOrderCount=",buyPostitionCount," SellOrderCount=",sellPositionCount);
         if(magic == 0 || o_magic == magic)
           {
            switch(type)
              {
               case        POSITION_TYPE_BUY  :
                  AddToList(ticket, BuyPositions);
                  buyPostitionCount++;
                  break;
               case        POSITION_TYPE_SELL  :
                  AddToList(ticket, SellPositions);
                  sellPositionCount++;
                  break;
              }
            //       Print(__FUNCTION__,__DATETIME__, ": cnt=", cnt, " t=",t, " type=",type," magic=",magic," ticket=",ticket," BuyOrderCount=",buyPostitionCount," SellOrderCount=",sellPositionCount);
           }
        }
     }
   cnt = OrdersTotal();
   for(int t = 0; t < cnt; t++)
     {
      ticket = (int) OrderGetTicket(t);
      if((ticket) > 0)
        {
         ENUM_ORDER_TYPE  type          = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
         int o_magic = (int)  OrderGetInteger(ORDER_MAGIC);
         if(magic == 0 || o_magic == magic)
           {
            switch(type)
              {
               case         ORDER_TYPE_BUY_LIMIT  :
                  AddToList(ticket, BuyOrders);
                  buyOrderCount++;
                  break;
               case         ORDER_TYPE_SELL_LIMIT  :
                  AddToList(ticket, SellOrders);
                  sellOrderCount++;
                  break;
               case         ORDER_TYPE_BUY_STOP  :
                  AddToList(ticket, BuyOrders);
                  buyOrderCount++;
                  break;
               case         ORDER_TYPE_SELL_STOP :
                  AddToList(ticket, SellOrders);
                  sellOrderCount++;
                  break;
              }
            //       Print(__FUNCTION__,__DATETIME__, ": type=",type," magic=",magic," ticket=",ticket," PendingBuyOrderCount=",
            //             PendingBuyOrderCount()," PendingSellOrderCount=",PendingSellOrderCount());
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int COrderMachine:: PositionTicketCount(int magic)
  {
   int cnt = PositionsTotal();
   int rescnt = 0;
   int ticket = 0;
   for(int t = 0; t < cnt; t++)
     {
      if((ticket = (int)PositionGetTicket(t)) > 0)
        {
         int o_magic = (int) PositionGetInteger(POSITION_MAGIC);
         if(magic == 0 || o_magic == magic)
           {
            rescnt++;
           }
        }
     }
   return rescnt;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int COrderMachine:: PositionTickets(int& list[])
  {
   int cnt = PositionsTotal();
   int ticket = 0;
   ArrayResize(list, cnt);
   for(int t = 0; t < cnt; t++)
     {
      if((ticket = (int) PositionGetTicket(t)) > 0)
         list[t] = ticket;
     }
   return cnt;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int COrderMachine:: OrderTickets(int& list[])
  {
   int cnt = OrdersTotal();
   int ticket = 0;
   ArrayResize(list, cnt);
   int rescnt = 0;
   for(int t = 0; t < cnt; t++)
     {
      if((ticket = (int) OrderGetTicket(t)) > 0)
        {
         ENUM_ORDER_TYPE  type          = (ENUM_ORDER_TYPE) EnumToString(ENUM_ORDER_TYPE(OrderGetInteger(ORDER_TYPE)));
         if(type > ORDER_TYPE_SELL)
           {
            list[rescnt] = ticket;
            rescnt++;
           }
        }
     }
   ArrayResize(list, rescnt);
   return rescnt;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_POSITION_TYPE COrderMachine:: PositionType(int ticket)
  {
   long ret;
   m_position.SelectByTicket(ticket);
   m_position.InfoInteger(POSITION_TYPE, ret);
   return (ENUM_POSITION_TYPE)ret;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double COrderMachine:: PositionProfit(int ticket)
  {
   double ret;
   m_position.SelectByTicket(ticket);
   m_position.InfoDouble(POSITION_PROFIT, ret);
   return ret;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double COrderMachine:: PositionOpenPrice(int ticket)
  {
   double ret;
   m_position.SelectByTicket(ticket);
   m_position.InfoDouble(POSITION_PRICE_OPEN, ret);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double COrderMachine:: PositionTakeProfit(int ticket)
  {
   double ret;
   m_position.SelectByTicket(ticket);
   m_position.InfoDouble(POSITION_TP, ret);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double COrderMachine:: PositionStopLoss(int ticket)
  {
   double ret;
   m_position.SelectByTicket(ticket);
   m_position.InfoDouble(POSITION_SL, ret);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime COrderMachine:: PositionOpenTime(int ticket)
  {
   long ret;
   m_position.SelectByTicket(ticket);
   m_position.InfoInteger(POSITION_TIME, ret);
   return (datetime)ret;
  }
//+------------------------------------------------------------------+
//| Close Order/Position                                             |
//+------------------------------------------------------------------+
bool COrderMachine::  PositionClose(
   int        ticket     // ticket
)
  {
   bool res = false;
//--- close position
   if(m_trade.PositionClose(ticket))
     {
      res = true;
      printf("Long position by %s to be closed", Symbol());
     }
   else
     {
      printf("Error closing position by %s : '%s'", Symbol(), m_trade.ResultComment());
      //--- processed and cannot be modified
     }
//--- result
   return(res);
  }
//+------------------------------------------------------------------+
//| Modify Order/Position                                             |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderMachine::PositionModify(
   int        ticket,      // ticket
   double     stoploss,    // stop loss
   double     takeprofit) // take profit
  {
   bool ret = false;
   if(m_position.SelectByTicket(ticket))
     {
      if(stoploss == 0)
         stoploss = PositionGetDouble(POSITION_SL);
      if(takeprofit == 0)
         takeprofit = PositionGetDouble(POSITION_TP);
      //--- modify position
      if(m_trade.PositionModify(ticket, stoploss, takeprofit))
        {
         printf("Short position ticket %d modified", ticket);
         ret = true;
        }
      else
        {
         printf("Error modifying ticket %d : '%s'", ticket, m_trade.ResultComment());
         printf("Modify parameters : SL=%f,TP=%f", stoploss, takeprofit);
        }
     }
//--- modified and must exit from expert
   return ret;
  }
//+------------------------------------------------------------------+
//| Modify Order/Position                                             |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderMachine::PositionModify(
   int        ticket,      // ticket
   int       sl,    // stop loss
   int     tp) // take profit
  {
   bool ret = false;
   double price = 0;
   double stoploss = 0;
   double takeprofit = 0;
   if(m_position.SelectByTicket(ticket))
     {
      price = PositionGetDouble(POSITION_PRICE_CURRENT);
      ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE) PositionGetInteger(POSITION_TYPE);
      if(type == POSITION_TYPE_BUY)
        {
         if(sl > 0)
            stoploss = price - sl * Point();
         else
            stoploss = PositionGetDouble(POSITION_SL);
         if(tp > 0)
            takeprofit = price + tp * Point();
         else
            takeprofit = PositionGetDouble(POSITION_TP);
        }
      else
        {
         if(sl > 0)
            stoploss = price + sl * Point();
         else
            stoploss = PositionGetDouble(POSITION_SL);
         if(tp > 0)
            takeprofit = price - tp * Point();
         else
            takeprofit = PositionGetDouble(POSITION_TP);
        }
      // calculate values for stoploss and takeprofit
      //--- modify position
      COrderMachine::PositionModify(ticket, stoploss, takeprofit);
     }
//--- modified and must exit from expert
   return ret;
  }


/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderMachine::PositionModify(int ticket, double slprice, double tpprice)
{
 if(m_position.SelectByTicket(ticket))
   {
    if(m_trade.PositionModify(Symbol(), slprice, tpprice))
       printf("position by %s to be modified", Symbol());
    else
      {
       printf("Error modifying position by %s : '%s'", Symbol(), m_trade.ResultComment());
       printf("Modify parameters : SL=%f,TP=%f", slprice, tpprice);
      }
   }
}
*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderMachine::PositionSetStop(int ticket, int stoploss)
  {
   return PositionSetStop(ticket, stoploss, 0);
  }
//+------------------------------------------------------------------+
//| Check for long position modifying                                |
//+------------------------------------------------------------------+
bool COrderMachine::PositionSetStop(int ticket, int stoploss, int minwinticks)
  {
   bool res = false;
   double win = 0;
//--- check for trailing stop
   if(stoploss > 0)
     {
      m_symbol.Name(Symbol());
      if(m_position.SelectByTicket(ticket))
        {
         double tsval = m_adjusted_point * stoploss;
         double o_stoploss = m_position.StopLoss();
         double tp = m_position.TakeProfit();
         if(m_position.PositionType() == POSITION_TYPE_BUY)
           {
            // Long
            win = m_symbol.Bid() - m_position.PriceOpen();
            if((win > tsval && (win > m_adjusted_point * minwinticks || minwinticks == 0 || o_stoploss != 0)))
               //   if(m_symbol.Bid()-m_position.PriceOpen()>tsval)
              {
               double sl = NormalizeDouble(m_symbol.Bid() - tsval, m_symbol.Digits());
               if(m_position.StopLoss() < sl || m_position.StopLoss() == 0.0)
                 {
                  //--- modify position
                  // Print(__FUNCTION__," SELL Position:  sl=",sl," tp=",tp);
                  if(m_trade.PositionModify(Symbol(), sl, tp))
                     printf("Long position by %s to be modified", Symbol());
                  else
                    {
                     printf("Error modifying position by %s : '%s'", Symbol(), m_trade.ResultComment());
                     printf("Modify parameters : SL=%f,TP=%f", sl, tp);
                    }
                  //--- modified and must exit from expert
                  res = true;
                 }
              }
           }
         if(m_position.PositionType() == POSITION_TYPE_SELL)
           {
            // Short
            win = m_position.PriceOpen() - m_symbol.Ask();
            if((win > tsval && (win > m_adjusted_point * minwinticks || minwinticks == 0 || o_stoploss != 0)))
               // if((m_position.PriceOpen()-m_symbol.Ask())>(tsval))
              {
               double sl = NormalizeDouble(m_symbol.Ask() + tsval, m_symbol.Digits());
               if(m_position.StopLoss() > sl || m_position.StopLoss() == 0.0)
                 {
                  //--- modify position
                  //    Print(__FUNCTION__," SELL Position:  sl=",sl," tp=",tp);
                  if(m_trade.PositionModify(Symbol(), sl, tp))
                     printf("Short position by %s to be modified", Symbol());
                  else
                    {
                     printf("Error modifying position by %s : '%s'", Symbol(), m_trade.ResultComment());
                     printf("Modify parameters : SL=%f,TP=%f", sl, tp);
                    }
                  //--- modified and must exit from expert
                  res = true;
                 }
              }
           }
        }
     }
//--- result
   return(res);
  }


//+------------------------------------------------------------------+
//| Check for short position opening                                 |
//+------------------------------------------------------------------+
int COrderMachine:: OrderSend(string   symbol,               // symbol
                              int      cmd,                 // operation
                              double   volume,              // volume
                              double   price,               // price
                              int      slippage,            // slippage
                              double   stoploss,            // stop loss
                              double   takeprofit,          // take profit
                              string   comment = NULL,      // comment
                              int      magic = 0,           // magic number
                              datetime expiration = 0)      // pending order expiration
  {
   bool res = false;
   m_symbol.Name(Symbol());
   m_trade.SetExpertMagicNumber(magic); // magic
// long
   if(cmd == ORDER_TYPE_BUY)
     {
      //--- check for free money
      if(m_account.FreeMarginCheck(Symbol(), ORDER_TYPE_BUY, volume, price) < 0.0)
         printf("We have no money. Free Margin = %f", m_account.FreeMargin());
      else
        {
         //--- open position
         if(m_trade.PositionOpen(Symbol(), ORDER_TYPE_BUY, volume, price, stoploss, takeprofit, comment))
           {
            printf("Position by %s to be opened", Symbol());
            res = true;
           }
         else
           {
            printf("Error opening BUY position by %s : '%s'", Symbol(), m_trade.ResultComment());
            printf("Open parameters : price=%f,SL=%f TP=%f", price, stoploss, takeprofit);
           }
        }
     }
   else
      if(cmd == ORDER_TYPE_SELL)
        {
         // short
         //--- check for free money
         if(m_account.FreeMarginCheck(Symbol(), ORDER_TYPE_SELL, volume, price) < 0.0)
            printf("We have no money. Free Margin = %f", m_account.FreeMargin());
         else
           {
            //--- open position
            if(m_trade.PositionOpen(Symbol(), ORDER_TYPE_SELL, volume, price, stoploss, takeprofit, comment))
              {
               printf("Position by %s to be opened", Symbol());
               res = true;
              }
            else
              {
               printf("Error opening SELL position by %s : '%s'", Symbol(), m_trade.ResultComment());
               printf("Open parameters : price=%f,SL=%f TP=%f", price, stoploss, takeprofit);
              }
           }
        }
      else
        {
         //const string symbol,const ENUM_ORDER_TYPE order_type,const double volume,const double limit_price,
         //                const double price,const double sl,const double tp,
         //                 ENUM_ORDER_TYPE_TIME type_time,const datetime expiration,const string comment
         if(m_trade.OrderOpen(Symbol(), (ENUM_ORDER_TYPE)cmd, volume, price, price, stoploss, takeprofit, ORDER_TIME_SPECIFIED, expiration, comment))
           {
            printf("Position by %s to be opened", Symbol());
            res = true;
           }
         else
           {
            printf("Error opening pending %d position by %s : '%s'", cmd, Symbol(), m_trade.ResultComment());
            printf("Open parameters : cmd=%d price=%f,SL=%f TP=%f Exp=%s", cmd, price, stoploss, takeprofit, TimeToString(expiration));
           }
        }
//--- result
   return(res);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderMachine::PositionSetTPSL(int ticket, int sl, int tp)
  {
   string msg = "";
   bool ret = false;
   m_symbol.Name(Symbol());
   if(m_position.SelectByTicket(ticket))
     {
      //long ticket = (int) m_position.Ticket();
      double   tpval = m_position.TakeProfit();
      double   slval = m_position.StopLoss();
      if(m_position.PositionType() == POSITION_TYPE_BUY)
        {
         if(tp > 0)
            tpval = NormalizeDouble(m_symbol.Ask() + tp * Point(), Digits());
         if(sl > 0)
            slval    = NormalizeDouble(m_symbol.Bid() - sl * Point(), Digits());
        }
      if(m_position.PositionType() == POSITION_TYPE_SELL)
        {
         if(tp > 0)
            tpval = NormalizeDouble(m_symbol.Bid() - tp * Point(), Digits());
         if(sl > 0)
            slval = NormalizeDouble(m_symbol.Ask() + sl * Point(), Digits());
        }
      // delete
      if(sl < 0)
         slval = 0;
      if(tp < 0)
         tpval = 0;
      if(m_trade.PositionModify(m_position.Ticket(), sl, tp))
        {
         printf("Long position by %s to be modified", Symbol());
         ret = true;
        }
      else
        {
         printf("Error modifying position by %s : '%s'", Symbol(), m_trade.ResultComment());
         printf("Modify parameters : SL=%f,TP=%f", sl, tp);
        }
     }
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderMachine::OrderModify(int ticket, double price, int stoploss, int takeprofit, datetime new_expiration)
  {
   string msg = "";
   double buyStopPrice = 0;
   double sellStopPrice = 0;
   double buyTPPrice = 0;
   double sellTPPrice = 0;
   int error;
   bool ret = false;
   m_symbol.Name(Symbol());
   if(m_order.Select(ticket))
     {
      string symbol        = m_order.Symbol();
      double open_price    = m_order.PriceOpen();
      double   tp = m_order.TakeProfit();
      double   sl = m_order.StopLoss();
      ENUM_ORDER_TYPE type          = (ENUM_ORDER_TYPE)m_order.OrderType();
      ENUM_ORDER_TYPE_TIME type_time = m_order.TypeTime();
      datetime expiration = m_order.TimeExpiration();
      double stoplimit = m_order.PriceStopLimit();
      if(new_expiration > 0)
        {
         expiration = new_expiration;
        }
      if(price > 0)
         open_price = price;
      double pp = Point();
      // pp = MarketInfo(OrderSymbol(),MODE_POINT);
      if(stoploss > 0)
        {
         stoploss = CheckStopLossPips(symbol, stoploss);
         sellStopPrice = open_price + pp * stoploss;
         buyStopPrice = open_price - pp * stoploss;
        }
      else
        {
         buyStopPrice = sl;
         sellStopPrice = sl;
        }
      if(takeprofit > 0)
        {
         takeprofit = CheckStopLossPips(symbol, takeprofit);
         sellTPPrice = open_price - pp * takeprofit;
         buyTPPrice = open_price + pp * takeprofit;
        }
      else
        {
         sellTPPrice = tp;
         buyTPPrice = tp;
        }
      sellStopPrice = CheckPriceVal(sellStopPrice);
      buyStopPrice = CheckPriceVal(buyStopPrice);
      sellTPPrice = CheckPriceVal(sellTPPrice);
      buyTPPrice = CheckPriceVal(buyTPPrice);
      if(stoploss > 0 || takeprofit > 0)
        {
         Print(__FUNCTION__, " StopLoss=" + (string)stoploss, " TakeProfit=" + (string)takeprofit);
         if(type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_BUY_STOP) // long position is opened
           {
            if(stoploss == 0)
               buyStopPrice = sl;
            if(takeprofit == 0)
               buyTPPrice = tp;
            ret = m_trade.OrderModify(ticket, open_price, buyStopPrice, buyTPPrice, type_time, expiration, stoplimit);
            if(!ret)
              {
               error = GetLastError();
               Print(__FUNCTION__, " Order #" + (string)ticket + " Error = ", ErrorDescription(error));
              }
           }
         if(type == ORDER_TYPE_SELL_LIMIT || type == ORDER_TYPE_SELL_STOP) // short position is opened
           {
            if(stoploss == 0)
               sellStopPrice = sl;
            if(takeprofit == 0)
               sellTPPrice = tp;
            ret = m_trade.OrderModify(ticket, open_price, sellStopPrice, sellTPPrice, type_time, expiration, stoplimit);
            if(!ret)
              {
               error = GetLastError();
               Print(__FUNCTION__, " Order #" + (string)ticket + " Error = ", ErrorDescription(error));
              }
           }
        }
     }
   return ret;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderMachine::OrderModify(int ticket, double price, double stopprice, double tpprice, datetime new_expiration)
  {
   string msg = "";
   double StopPrice = 0;
   double TPPrice = 0;
   int error;
   bool ret = false;
   m_symbol.Name(Symbol());
   if(m_order.Select(ticket))
     {
      string symbol        = m_order.Symbol();
      double open_price    = m_order.PriceOpen();
      double   takeprofit = m_order.TakeProfit();
      double   stoploss = m_order.StopLoss();
      ENUM_ORDER_TYPE type          = (ENUM_ORDER_TYPE) m_order.OrderType();
      ENUM_ORDER_TYPE_TIME type_time = m_order.TypeTime();
      datetime expiration = m_order.TimeExpiration();
      double stoplimit = m_order.PriceStopLimit();
      if(new_expiration > 0)
         expiration = new_expiration;
      if(price > 0)
         open_price = price;
      if(stopprice > 0)
        {
         StopPrice = stopprice;
        }
      else
        {
         StopPrice = stoploss;
        }
      if(tpprice > 0)
        {
         TPPrice = tpprice;
        }
      else
        {
         TPPrice = takeprofit;
        }
      StopPrice = CheckPriceVal(StopPrice);
      ret = m_trade.OrderModify(ticket, open_price, StopPrice, TPPrice, type_time, expiration, stoplimit);
      if(!ret)
        {
         error = GetLastError();
         Print(__FUNCTION__, " Order #" + (string)ticket + " Error = ", ErrorDescription(error));
        }
     }
   return ret;
  }


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
