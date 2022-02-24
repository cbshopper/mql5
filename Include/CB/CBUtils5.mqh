//+------------------------------------------------------------------+
//|                                                     CBUtils5.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#ifndef MODE_TRADES
#define MODE_TRADES 0
#define MODE_HISTORY 1
#define SELECT_BY_POS 0
#define SELECT_BY_TICKET 1
#endif
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ObjectFind(string name)
  {
   return ObjectFind(0, name);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ObjectDelete(string name)
  {
   return ObjectDelete(0, name);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  ObjectCreate(string name, ENUM_OBJECT obj, int subwindow, datetime time, double value)
  {
   return ObjectCreate(0, name, obj, subwindow, time, value);
  }
/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   OrderSelect(int val int select_type, int trademode)
  {
   if(select_type == SELECT_BY_TICKET)
     {
      if(trademode == MODE_TRADES)
        {
         return PositionSelectByTicket(val);
        }
      else
        {
         return HistoryDealSelect(val);
        }
     }
   if(select_type == SELECT_BY_POS)
     {
      if(trademode == MODE_TRADES)
        {
         int ticket = (int) OrderGetTicket(val);
         if(ticket > -1)
            return OrderSelect(ticket);
        }
      else
        {
         int ticket = (int) HistoryDealGetTicket(val);
         if(ticket > -1)
            return HistoryDealSelect(ticket);
        }
     }
   return false;
  }
*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string OrderSymbol()
  {
   return OrderGetString(ORDER_SYMBOL);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OrderType()
  {
   return (int) OrderGetInteger(ORDER_TYPE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OrderPrint()
  {
   Print(__FUNCTION__, OrderGetString(ORDER_SYMBOL), ":", OrderGetInteger(ORDER_MAGIC));
  }
