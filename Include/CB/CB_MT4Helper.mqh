//+------------------------------------------------------------------+
//|                                                       CB_MT4.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//---
#ifndef MODE_TRADES
#define MODE_TRADES 0
#define MODE_HISTORY 1
#define SELECT_BY_POS 0
#define SELECT_BY_TICKET 1
#endif

#define OP_BUY 0           //Buy
#define OP_SELL 1          //Sell
#define OP_BUYLIMIT 2      //BUY LIMIT pending order
#define OP_SELLLIMIT 3     //SELL LIMIT pending order  
#define OP_BUYSTOP 4       //BUY STOP pending order  
#define OP_SELLSTOP 5      //SELL STOP pending order  

#define MODE_LOW 1
#define MODE_HIGH 2
#define MODE_TIME 5
#define MODE_BID 9
#define MODE_ASK 10
#define MODE_POINT 11
#define MODE_DIGITS 12
#define MODE_SPREAD 13
#define MODE_STOPLEVEL 14
#define MODE_LOTSIZE 15
#define MODE_TICKVALUE 16
#define MODE_TICKSIZE 17
#define MODE_SWAPLONG 18
#define MODE_SWAPSHORT 19
#define MODE_STARTING 20
#define MODE_EXPIRATION 21
#define MODE_TRADEALLOWED 22
#define MODE_MINLOT 23
#define MODE_LOTSTEP 24
#define MODE_MAXLOT 25
#define MODE_SWAPTYPE 26
#define MODE_PROFITCALCMODE 27
#define MODE_MARGINCALCMODE 28
#define MODE_MARGININIT 29
#define MODE_MARGINMAINTENANCE 30
#define MODE_MARGINHEDGED 31
#define MODE_MARGINREQUIRED 32
#define MODE_FREEZELEVEL 33


int Bars() {return Bars(_Symbol, _Period);}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Ask()
  {
   MqlTick last_tick;
   SymbolInfoTick(_Symbol, last_tick);
   return last_tick.ask;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Bid()
  {
   MqlTick last_tick;
   SymbolInfoTick(_Symbol, last_tick);
   return last_tick.bid;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MarketInfo(string symbol, int type)
// With hacks to match integer type into double.
  {
   switch(type)
     {
      case MODE_LOW:
         return(SymbolInfoDouble(symbol, SYMBOL_LASTLOW));
      case MODE_HIGH:
         return(SymbolInfoDouble(symbol, SYMBOL_LASTHIGH));
      case MODE_TIME:
         return((double)  SymbolInfoInteger(symbol, SYMBOL_TIME));
      case MODE_BID:
         return(Bid());
      case MODE_ASK:
         return(Ask());
      case MODE_POINT:
         return(SymbolInfoDouble(symbol, SYMBOL_POINT));
      case MODE_DIGITS:
         return((double) SymbolInfoInteger(symbol, SYMBOL_DIGITS));
      case MODE_SPREAD:
         return((double) SymbolInfoInteger(symbol, SYMBOL_SPREAD));
      case MODE_STOPLEVEL:
         return((double) SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL));
      case MODE_LOTSIZE:
         return(SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE));
      case MODE_TICKVALUE:
         return(SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE));
      case MODE_TICKSIZE:
         return(SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE));
      case MODE_SWAPLONG:
         return(SymbolInfoDouble(symbol, SYMBOL_SWAP_LONG));
      case MODE_SWAPSHORT:
         return(SymbolInfoDouble(symbol, SYMBOL_SWAP_SHORT));
      case MODE_STARTING:
         return(0);
      case MODE_EXPIRATION:
         return(0);
      case MODE_TRADEALLOWED:
         return(0);
      case MODE_MINLOT:
         return(SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN));
      case MODE_LOTSTEP:
         return(SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP));
      case MODE_MAXLOT:
         return(SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX));
      case MODE_SWAPTYPE:
         return((double) SymbolInfoInteger(symbol, SYMBOL_SWAP_MODE));
      case MODE_PROFITCALCMODE:
         return((double) SymbolInfoInteger(symbol, SYMBOL_TRADE_CALC_MODE));
      case MODE_MARGINCALCMODE:
         return(0);
      case MODE_MARGININIT:
         return(0);
      case MODE_MARGINMAINTENANCE:
         return(0);
      case MODE_MARGINHEDGED:
         return(0);
      case MODE_MARGINREQUIRED:
         return(0);
      case MODE_FREEZELEVEL:
         return((double) SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL));
      default:
         return(0);
     }
   return(0);
  }


//Date and Time Functions
int Day()
  {
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.day);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int DayOfWeek()
  {
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.day_of_week);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int DayOfYear()
  {
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.day_of_year);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Hour()
  {
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.hour);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Minute()
  {
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.min);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Month()
  {
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.mon);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Seconds()
  {
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.sec);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeDay(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date, tm);
   return(tm.day);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeDayOfWeek(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date, tm);
   return(tm.day_of_week);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeDayOfYear(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date, tm);
   return(tm.day_of_year);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeHour(datetime time)
  {
   MqlDateTime tm;
   TimeToStruct(time, tm);
   return(tm.hour);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeMinute(datetime time)
  {
   MqlDateTime tm;
   TimeToStruct(time, tm);
   return(tm.min);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeMonth(datetime time)
  {
   MqlDateTime tm;
   TimeToStruct(time, tm);
   return(tm.mon);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeSeconds(datetime time)
  {
   MqlDateTime tm;
   TimeToStruct(time, tm);
   return(tm.sec);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeYear(datetime time)
  {
   MqlDateTime tm;
   TimeToStruct(time, tm);
   return(tm.year);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Year()
  {
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.year);
  }
// Account Information
double AccountBalance()
  {
   return AccountInfoDouble(ACCOUNT_BALANCE);
  }

//+------------------------------------------------------------------+
