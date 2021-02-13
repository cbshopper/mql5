//+------------------------------------------------------------------+
//|                                            CB_OrderFunctions.mqh |
//|                                                   Christof Blank |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Christof Blank"
#property link      "https://www.mql5.com"
//#property strict
#include <cb\stderror.mqh>
#include <cb\ErrorMsg.mqh>
#include <cb\CB_Pips&Lots.mqh>
//#include <debug_inc.mqh>
//--- declaration of constants
#define OP_BUY 0           //Buy
#define OP_SELL 1          //Sell
#define OP_BUYLIMIT 2      //BUY LIMIT pending order
#define OP_SELLLIMIT 3     //SELL LIMIT pending order  
#define OP_BUYSTOP 4       //BUY STOP pending order  
#define OP_SELLSTOP 5      //SELL STOP pending order  


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
   int               buyOrderCount;
   int               sellOrderCount;
   int               pendingBuyOrderCount;
   int               pendingSellOrderCount;

public:
                     COrderMachine(void);
                    ~COrderMachine(void);

   CTrade            m_trade;                      // trading object
   CSymbolInfo       m_symbol;                     // symbol info object
   CPositionInfo     m_position;                   // trade position object
   CAccountInfo      m_account;                    // account info wrapper

   int               BuyOrders[];
   int               SellOrders[];
   int               PendingBuyOrders[];
   int               PendingSellOrders[];


   bool              Init(void);
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
                               datetime expiration,        // pending order expiration
                               color    arrow_color);

   bool              OrderModify(
      int        ticket,      // ticket
      double     price,       // price
      double     stoploss,    // stop loss
      double     takeprofit,  // take profit
      datetime   expiration,  // expiration
      color      arrow_color);   // color

   bool              OrderClose(
      int        ticket,      // ticket
      double     price,       // close price
      int        slippage,    // slippage
      color      arrow_color  // color
   );
   double            OrderProfit(int ticket);
   double            OrderOpenPrice(int ticket);
   double            OrderTakeProfit(int ticket);
   double            OrderStopLoss(int ticket);
   datetime          OrderOpenTime(int ticket);
   void              UpdateOrderList(int magic);
   bool              OrderSetSLTP(int magic, int sl, int tp);
   bool              PendingOrderSetSLTP(int magic, int sl, int tp);
   bool              OrderSetStop(int ticket, int trailingstop,int minwinticks);
   bool              OrderSetStop(int ticket, int trailingstop);
   int               BuyOrderCount(void) const {return buyOrderCount;}
   int               SellOrderCount(void)  const {return sellOrderCount;}
   int               PendingBuyOrderCount(void)  const {return pendingBuyOrderCount;}
   int               PendingSellOrderCount(void) const {return pendingSellOrderCount;}


protected:
   bool              InitCheckParameters(const int digits_adjust);
   int               AddToList(int item, int &list[]);

   int               OpenOrderTicketCount(int magic);
   int               OrderTickets(int& list[]);
   int               OpenOrderTickets(int& list[]);
   int               PendingOrderTickets(int& list[]);

  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
COrderMachine::COrderMachine(void)
  {

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
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//--- set default deviation for trading in adjusted points
   m_trade.SetDeviationInPoints(3*digits_adjust);
//---
//--- succeed
   return(true);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int COrderMachine::AddToList(int item, int& list[])
  {
   int len = ArraySize(list);
   ArrayResize(list,len+1);
   list[len]= item;
   return len+1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void COrderMachine:: UpdateOrderList(int magic)
  {

   int ticket=0;
   buyOrderCount=0;
   sellOrderCount=0;
   pendingBuyOrderCount=0;
   pendingSellOrderCount=0;
   ArrayResize(BuyOrders,0);
   ArrayResize(SellOrders,0);
   ArrayResize(PendingBuyOrders,0);
   ArrayResize(PendingSellOrders,0);


   int cnt = PositionsTotal();
   for(int t = 0; t < cnt; t++)
     {
      ticket=PositionGetTicket(t);
      if((ticket)>0)
        {
         ENUM_POSITION_TYPE  type          =(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         int o_magic = PositionGetInteger(POSITION_MAGIC);
       //  Print(__FUNCTION__,__DATETIME__, ": cnt=", cnt, " t=",t, " type=",type," magic=",magic," omagic=",o_magic," ticket=",ticket," BuyOrderCount=",buyOrderCount," SellOrderCount=",sellOrderCount);

         if(magic == 0 || o_magic == magic)
           {

            switch(type)
              {
               case        POSITION_TYPE_BUY  :
                  AddToList(ticket,BuyOrders);
                  buyOrderCount++;
                  break;
               case        POSITION_TYPE_SELL  :
                  AddToList(ticket,SellOrders);
                  sellOrderCount++;
                  break;
              }
     //       Print(__FUNCTION__,__DATETIME__, ": cnt=", cnt, " t=",t, " type=",type," magic=",magic," ticket=",ticket," BuyOrderCount=",buyOrderCount," SellOrderCount=",sellOrderCount);
           
           }

        }
     }

   cnt = OrdersTotal();
   for(int t = 0; t < cnt; t++)
     {
      ticket=OrderGetTicket(t);
      if((ticket)>0)
        {
         ENUM_ORDER_TYPE  type          =(ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
         int o_magic = OrderGetInteger(ORDER_MAGIC);

         if(magic == 0 || o_magic == magic)
           {
            switch(type)
              {
               case         ORDER_TYPE_BUY_LIMIT  :
                  AddToList(ticket,PendingBuyOrders);
                  pendingBuyOrderCount++;
                  break;
               case         ORDER_TYPE_SELL_LIMIT  :
                  AddToList(ticket,PendingSellOrders);
                  pendingSellOrderCount++;
                  break;
               case         ORDER_TYPE_BUY_STOP  :
                  AddToList(ticket,PendingBuyOrders);
                  pendingBuyOrderCount++;
                  break;
               case         ORDER_TYPE_SELL_STOP :
                  AddToList(ticket,PendingSellOrders);
                  pendingSellOrderCount++;
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
int COrderMachine:: OpenOrderTicketCount(int magic)
  {
   int cnt = OrdersTotal();
   int rescnt=0;
   int ticket=0;
   for(int t = 0; t < cnt; t++)
     {
      if((ticket=OrderGetTicket(t))>0)
        {
         ENUM_ORDER_TYPE  type  =EnumToString(ENUM_ORDER_TYPE(OrderGetInteger(ORDER_TYPE)));

         if(type <= ORDER_TYPE_SELL)
           {
            int o_magic = OrderGetInteger(ORDER_MAGIC);
            if(magic == 0 || o_magic == magic)
              {
               rescnt++;
              }
           }
        }
     }
   return rescnt;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int COrderMachine:: OrderTickets(int& list[])
  {
   int cnt = OrdersTotal();
   int ticket = 0;
   ArrayResize(list,cnt);
   for(int t = 0; t < cnt; t++)
     {
      if((ticket=OrderGetTicket(t))>0)

         list[t] =ticket;
     }
   return cnt;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int COrderMachine:: PendingOrderTickets(int& list[])
  {
   int cnt = OrdersTotal();
   int ticket = 0;
   ArrayResize(list,cnt);
   int rescnt=0;
   for(int t = 0; t < cnt; t++)
     {
      if((ticket=OrderGetTicket(t))>0)
        {
         ENUM_ORDER_TYPE  type          =EnumToString(ENUM_ORDER_TYPE(OrderGetInteger(ORDER_TYPE)));
         if(type >ORDER_TYPE_SELL)
           {
            list[rescnt] =ticket;
            rescnt++;
           }
        }
     }
   ArrayResize(list,rescnt);
   return rescnt;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int COrderMachine:: OpenOrderTickets(int& list[])
  {
   int cnt = OrdersTotal();
   int ticket = 0;
   ArrayResize(list,cnt);
   int rescnt=0;
   for(int t = 0; t < cnt; t++)
     {
      if((ticket=OrderGetTicket(t))>0)
        {
         ENUM_ORDER_TYPE  type          =EnumToString(ENUM_ORDER_TYPE(OrderGetInteger(ORDER_TYPE)));
         if(type <= ORDER_TYPE_SELL)
           {
            list[rescnt] =ticket;
            rescnt++;
           }
        }
     }
   ArrayResize(list,rescnt);
   return rescnt;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double COrderMachine:: OrderProfit(int ticket)
  {
   double ret;
   m_position.SelectByTicket(ticket);
   m_position.InfoDouble(POSITION_PROFIT,ret);
   return ret;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double COrderMachine:: OrderOpenPrice(int ticket)
  {
   double ret;
   m_position.SelectByTicket(ticket);
   m_position.InfoDouble(POSITION_PRICE_OPEN,ret);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double COrderMachine:: OrderTakeProfit(int ticket)
  {
   double ret;
   m_position.SelectByTicket(ticket);
   m_position.InfoDouble(POSITION_TP,ret);
   return ret;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double COrderMachine:: OrderStopLoss(int ticket)
  {
   double ret;
   m_position.SelectByTicket(ticket);
   m_position.InfoDouble(POSITION_SL,ret);
   return ret;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime COrderMachine:: OrderOpenTime(int ticket)
  {
   long ret;
   m_position.SelectByTicket(ticket);
   m_position.InfoInteger(POSITION_TIME,ret);
   return (datetime)ret;

  }
//+------------------------------------------------------------------+
//| Close Order/Position                                             |
//+------------------------------------------------------------------+
bool COrderMachine::  OrderClose(
   int        ticket,      // ticket
   double     price,       // close price
   int        slippage,    // slippage
   color      arrow_color  // color
)
  {
   bool res=false;
//--- close position

   if(m_trade.PositionClose(ticket))
     {
      res=true;

      printf("Long position by %s to be closed",Symbol());
     }
   else
     {
      printf("Error closing position by %s : '%s'",Symbol(),m_trade.ResultComment());
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
bool COrderMachine::OrderModify(
   int        ticket,      // ticket
   double     price,       // price
   double     stoploss,    // stop loss
   double     takeprofit,  // take profit
   datetime   expiration,  // expiration
   color      arrow_color)   // color
  {
   bool ret=false;
//--- modify position
   if(m_trade.PositionModify(ticket,stoploss,takeprofit))
     {
      printf("Short position ticket %d modified",ticket);
      ret=true;
     }
   else
     {
      printf("Error modifying ticket %d : '%s'",ticket,m_trade.ResultComment());
      printf("Modify parameters : SL=%f,TP=%f",stoploss,takeprofit);
     }
//--- modified and must exit from expert

   return ret;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderMachine::OrderSetStop(int ticket, int stoploss)
  {
   return OrderSetStop(ticket, stoploss,0);
  }
//+------------------------------------------------------------------+
//| Check for long position modifying                                |
//+------------------------------------------------------------------+
bool COrderMachine::OrderSetStop(int ticket, int stoploss,int minwinticks)
  {
   bool res=false;
   double win =0;
//--- check for trailing stop
   if(stoploss>0)
     {
      m_symbol.Name(Symbol());

      if(m_position.SelectByTicket(ticket))
        {
         double tsval = m_adjusted_point*stoploss;
         double o_stoploss= m_position.StopLoss();
         if(m_position.PositionType() == POSITION_TYPE_BUY)
           {
            // Long

            win=m_symbol.Bid()-m_position.PriceOpen();
            if((win>tsval && (win>m_adjusted_point*minwinticks || minwinticks==0 ||o_stoploss!=0)))
               //   if(m_symbol.Bid()-m_position.PriceOpen()>tsval)
              {
               double sl=NormalizeDouble(m_symbol.Bid()-tsval,m_symbol.Digits());
               double tp=m_position.TakeProfit();
               if(m_position.StopLoss()<sl || m_position.StopLoss()==0.0)
                 {
                  //--- modify position
                  if(m_trade.PositionModify(Symbol(),sl,tp))
                     printf("Long position by %s to be modified",Symbol());
                  else
                    {
                     printf("Error modifying position by %s : '%s'",Symbol(),m_trade.ResultComment());
                     printf("Modify parameters : SL=%f,TP=%f",sl,tp);
                    }
                  //--- modified and must exit from expert
                  res=true;
                 }
              }
           }
         if(m_position.PositionType() == POSITION_TYPE_SELL)
           {
            // Short
            win=m_position.PriceOpen()-m_symbol.Ask();
            if((win>tsval && (win>m_adjusted_point*minwinticks || minwinticks==0 || o_stoploss!=0)))
               // if((m_position.PriceOpen()-m_symbol.Ask())>(tsval))
              {
               double sl=NormalizeDouble(m_symbol.Ask()+tsval,m_symbol.Digits());
               double tp=m_position.TakeProfit();
               if(m_position.StopLoss()>sl || m_position.StopLoss()==0.0)
                 {
                  //--- modify position
                  if(m_trade.PositionModify(Symbol(),sl,tp))
                     printf("Short position by %s to be modified",Symbol());
                  else
                    {
                     printf("Error modifying position by %s : '%s'",Symbol(),m_trade.ResultComment());
                     printf("Modify parameters : SL=%f,TP=%f",sl,tp);
                    }
                  //--- modified and must exit from expert
                  res=true;
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
                              string   comment=NULL,        // comment
                              int      magic=0,             // magic number
                              datetime expiration=0,        // pending order expiration
                              color    arrow_color=clrNONE)  // color )
  {
   bool res=false;
   m_symbol.Name(Symbol());
    m_trade.SetExpertMagicNumber(magic); // magic
// long
   if(cmd ==OP_BUY)
     {

     
      //--- check for free money
      if(m_account.FreeMarginCheck(Symbol(),ORDER_TYPE_BUY,volume,price)<0.0)
         printf("We have no money. Free Margin = %f",m_account.FreeMargin());
      else
        {
         //--- open position
         if(m_trade.PositionOpen(Symbol(),ORDER_TYPE_BUY,volume,price,stoploss,takeprofit,comment))
           {
            printf("Position by %s to be opened",Symbol());
            res=true;
           }
         else
           {
            printf("Error opening BUY position by %s : '%s'",Symbol(),m_trade.ResultComment());
            printf("Open parameters : price=%f,SL=%f TP=%f",price,stoploss,takeprofit);
           }
        }
     }
   else
      if(cmd == OP_SELL)
        {
         // short

         //--- check for free money
         if(m_account.FreeMarginCheck(Symbol(),ORDER_TYPE_SELL,volume,price)<0.0)
            printf("We have no money. Free Margin = %f",m_account.FreeMargin());
         else
           {
            //--- open position
            if(m_trade.PositionOpen(Symbol(),ORDER_TYPE_SELL,volume,price,stoploss,takeprofit,comment))
              {
               printf("Position by %s to be opened",Symbol());
               res=true;
              }
            else
              {
               printf("Error opening SELL position by %s : '%s'",Symbol(),m_trade.ResultComment());
               printf("Open parameters : price=%f,SL=%f TP=%f",price,stoploss,takeprofit);
              }
           }
        }
      else
        {
         //const string symbol,const ENUM_ORDER_TYPE order_type,const double volume,const double limit_price,
         //                const double price,const double sl,const double tp,
         //                 ENUM_ORDER_TYPE_TIME type_time,const datetime expiration,const string comment
         if(m_trade.OrderOpen(Symbol(),(ENUM_ORDER_TYPE)cmd,volume,price,price,stoploss,takeprofit,ORDER_TIME_SPECIFIED,expiration,comment))
           {
            printf("Position by %s to be opened",Symbol());
            res=true;
           }
         else
           {
            printf("Error opening pending %d position by %s : '%s'",cmd,Symbol(),m_trade.ResultComment());
            printf("Open parameters : cmd=%d price=%f,SL=%f TP=%f Exp=%s",cmd,price,stoploss,takeprofit,TimeToString(expiration));
           }
        }


//--- result
   return(res);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderMachine::OrderSetSLTP(int ticket, int sl, int tp)
  {
   string msg = "";
   bool ret=false;
   m_symbol.Name(Symbol());

   if(m_position.SelectByTicket(ticket))
     {
      if(m_position.Type() <= ORDER_TYPE_SELL)
        {
         long MagicNumber=0;
         m_position.InfoInteger(POSITION_MAGIC,MagicNumber);
         string symbol = "";
         m_position.InfoString(POSITION_SYMBOL,symbol);
         if(symbol == Symbol())
           {
            long ticket = m_position.Ticket();
            double   tpval = m_position.TakeProfit();
            double   slval = m_position.StopLoss();
            if(m_position.PositionType() == POSITION_TYPE_BUY)
              {
               if(tp >0)
                  tpval = NormalizeDouble(m_symbol.Ask() + tp*Point(),Digits());
               if(sl >0)
                  slval    = NormalizeDouble(m_symbol.Bid() - sl*Point(),Digits());

              }
            if(m_position.PositionType() == POSITION_TYPE_SELL)
              {
               if(tp >0)
                  tpval = NormalizeDouble(m_symbol.Bid() - tp*Point(),Digits());
               if(sl >0)
                  slval = NormalizeDouble(m_symbol.Ask() + sl*Point(),Digits());
              }
            // delete
            if(sl < 0)
               slval=0;
            if(tp < 0)
               tpval=0;
            if(m_trade.PositionModify(m_position.Ticket(),sl,tp))
              {
               printf("Long position by %s to be modified",Symbol());
               ret = true;
              }
            else
              {
               printf("Error modifying position by %s : '%s'",Symbol(),m_trade.ResultComment());
               printf("Modify parameters : SL=%f,TP=%f",sl,tp);
              }
           }
        }
     }
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COrderMachine::PendingOrderSetSLTP(int ticket, int StoppLoss, int TakeProfit)
  {
   string msg = "";
   double buyStopPrice=0;
   double sellStopPrice=0;
   double buyTPPrice=0;
   double sellTPPrice=0;
   string symbol;
   int error;
   bool ret=false;

   m_symbol.Name(Symbol());


   if(m_position.SelectByTicket(ticket))
     {
      if(m_position.Type() <= ORDER_TYPE_SELL)
        {
         if(symbol == Symbol())
           {
            string symbol        = m_position.Symbol();
            double open_price    =OrderGetDouble(ORDER_PRICE_OPEN);
            double   takeprofit = m_position.TakeProfit();
            double   stoploss = m_position.StopLoss();
            ENUM_ORDER_TYPE type          =m_position.Type();
            double pp=Point();
            // pp = MarketInfo(OrderSymbol(),MODE_POINT);
            if(StoppLoss>0)
              {
               StoppLoss=CheckStopLossPips(symbol,StoppLoss);
               sellStopPrice=open_price+pp*StoppLoss;
               buyStopPrice=open_price-pp*StoppLoss;
              }
            else
              {
               buyStopPrice=stoploss;
               sellStopPrice=stoploss;
              }
            if(TakeProfit>0)
              {
               TakeProfit=CheckStopLossPips(symbol,TakeProfit);
               sellTPPrice=open_price-pp*TakeProfit;
               buyTPPrice=open_price+pp*TakeProfit;
              }
            else
              {
               sellTPPrice=takeprofit;
               buyTPPrice=takeprofit;
              }

            sellStopPrice = CheckPriceVal(sellStopPrice);
            buyStopPrice = CheckPriceVal(buyStopPrice);
            sellTPPrice = CheckPriceVal(sellTPPrice);
            buyTPPrice = CheckPriceVal(buyTPPrice);
            if(StoppLoss>0 || TakeProfit>0)
              {
               if(type==ORDER_TYPE_BUY_LIMIT || type==ORDER_TYPE_BUY_STOP) // long position is opened
                 {
                  if(stoploss==0 || takeprofit==0)
                    {
                     Print(__FUNCTION__," TrailingStop="+(string)StoppLoss," TakeProfit="+(string)TakeProfit);
                     ret = m_trade.PositionModify(ticket,buyStopPrice,buyTPPrice);
                     if(!ret)
                       {
                        error=GetLastError();
                        Print(__FUNCTION__," Order #"+(string)ticket+" Error = ",ErrorDescription(error));
                       }
                    }
                 }
               if(type==ORDER_TYPE_SELL_LIMIT || type==ORDER_TYPE_SELL_STOP) // short position is opened
                 {
                  if(stoploss==0 || takeprofit==0)
                    {
                     Print(__FUNCTION__," TrailingStop="+(string)StoppLoss);
                     ret= m_trade.PositionModify(ticket,sellStopPrice,sellTPPrice);
                     if(!ret)
                       {
                        error=GetLastError();
                        Print(__FUNCTION__," Order #"+(string)ticket+" Error = ",ErrorDescription(error));
                       }
                    }
                 }
              }
           }
        }
     }
   return ret;
  }





COrderMachine OrderMachine;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int               OrderSend(string   symbol,               // symbol
                            int      cmd,                 // operation
                            double   volume,              // volume
                            double   price,               // price
                            int      slippage,            // slippage
                            double   stoploss,            // stop loss
                            double   takeprofit,          // take profit
                            string   comment,        // comment
                            int      magic,             // magic number
                            datetime expiration,        // pending order expiration
                            color    arrow_color)
  {
   return OrderMachine.OrderSend(symbol,cmd,volume,price,slippage,stoploss,takeprofit,comment,magic,arrow_color);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool              OrderModify(
   int        ticket,      // ticket
   double     price,       // price
   double     stoploss,    // stop loss
   double     takeprofit,  // take profit
   datetime   expiration,  // expiration
   color      arrow_color)   // color
  {
   return OrderMachine.OrderModify(ticket,price,stoploss,takeprofit,expiration,arrow_color);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool              OrderClose(
   int        ticket,      // ticket
   double     price,       // close price
   int        slippage,    // slippage
   color      arrow_color  // color
)
  {
   return OrderMachine.OrderClose(ticket,price,slippage,arrow_color);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OrderOpenPrice(int ticket)
  {
   return OrderMachine.OrderOpenPrice(ticket);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OrderTakeProfit(int ticket)
  {
   return OrderMachine.OrderTakeProfit(ticket);
  }
//+------------------------------------------------------------------+
double OrderStopLoss(int ticket)
  {
   return OrderMachine.OrderStopLoss(ticket);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double OrderOpenTime(int ticket)
  {
   return OrderMachine.OrderOpenTime(ticket);
  }

//+------------------------------------------------------------------+
