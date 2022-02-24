//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <cb\CB_IndicatorHelper.mqh>
#include <cb\CBUtils5.mqh>


#ifndef CLOSE_SETTINGS
#ifdef EXITSLTP
input int CloseByFixSL=0;
input int ClosebyFixTP=0;
#else
int CloseByFixSL=0;
int ClosebyFixTP=0;
#endif

#ifdef EXITRISC
input int CloseByRiskSL=0;
input int CloseByRiskTP=0;
#else
int CloseByRiskSL=0;
int CloseByRiskTP=0;
#endif

#ifdef EXITATR
input int CloseByATRSL=0;
input int CloseByATRTP=0;
#else
int CloseByATRSL=0;
int CloseByATRTP=0;
#endif

#ifdef EXITHILO
input int ClosebyHILOSL=0;
input int ClosebyHILOTP=0;
#else
int ClosebyHILOSL=0;
int ClosebyHILOTP=0;
#endif
#endif
input string           EXIT_Settings = " ------- EXIT MODE  Settings ------ ";
//input ENUM_EXITMODES    ExitMode = MODE_EXIT_BYSIGNAL;
//input bool             UseExitSigalAlso = false;

#ifdef EXITSLTP
input string           ExitFixStopSettings = " ------- MODE_EXIT_EXIT Settings ------ ";
input int              TakeProfit = 400;
input int              StopLoss = 200;
// input double            Lots = 0.1;
#else
int                     TakeProfit = 0;
int                     StopLoss = 0;
#endif

input int              TrailingStop = 0;

#ifdef EXITATR
input string           ExitATRStopSettings = " ------- MODE_EXIT_ATR Settings ------ ";
input int              StopATRPeriod = 20;
input int              StopATRMultiplier = 5;
//input bool             ATRSetTP=false;
input int              ATRMaxStopLoss=0;

#ifndef EXITRISC
input double           CRV = 2.0;
#endif
#else
int                     StopATRPeriod = 0;
int                     StopATRMultiplier = 0;
//bool                    ATRSetTP=false;
int                     ATRMaxStopLoss=0;
#endif


#ifdef EXITHILO
input string            Exit_HILO = " ------- MODE_EXIT_HILO Settings ------ ";
input int               HILOBackBars = 10;
input int               MaxSL = 100;
#else
int               HILOBackBars = 10;
int               MaxSL = 100;
#endif

#ifdef EXITRISC
input string            ExitRiskSettings = " ------- MODE_EXIT_RISC Settings ------ ";
input double           MaxAccountValue = 10000;
input double            Risk = 1.0 ; // Risk percent per order
input double            iCRV = 2.0;
#else
double           MaxAccountValue = 10000;
double            Risk = 1.0 ; // Risk percent per order
double            iCRV = 2.0;
#endif

int ATRPtr=INVALID_HANDLE;
void InitSLTPCalculator()
  {
   if(ATRPtr==INVALID_HANDLE)
     {
      ATRPtr = iATR(NULL, 0, StopATRPeriod);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeInitSLTPCalculator()
  {
   if(ATRPtr==INVALID_HANDLE)
     {
      IndicatorRelease(ATRPtr);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateTPSL(int iStoploss, int iTakeprofit, double lots,double crv, int mode,int shift, int& stoploss, int& takeprofit)
  {
   if(crv==0)
      crv=1.0;
   int sl =0;
   int tp =0;
   int x =0;

   if(CloseByFixSL>0)
     {
      sl = iStoploss;
      // take Setting of StopLoss
     }
   if(ClosebyFixTP>0)
     {
      // take Setting of TakeProfit
      tp = iTakeprofit;
     }
   if(ClosebyHILOSL>0)
     {
      x = CalculateLastHILOStop(mode,  shift);
      if(x > sl || sl==0)
         sl =x;
     }
   if(ClosebyHILOTP>0)
     {
      x = CalculateLastHILOStop(mode,  shift)*crv;
      if(x > tp || tp==0)
         tp =x;
     }

   if(CloseByATRSL>0)
     {
      x=CalculateATR_SL(shift);
      if(x > sl || sl==0)
         sl =x;
     }

   if(CloseByATRTP>0)
     {
      x=CalculateATR_SL(shift)*crv;
      if(x > tp || tp==0)
         tp =x;
     }

   if(CloseByRiskSL>0)
     {
      x=CalculateRiskStop(lots);
      if(x > sl || sl==0)
         sl =x;
     }
   if(CloseByRiskTP>0)
     {
      x=CalculateRiskStop(lots)*crv;
      if(x > tp || tp==0)
         tp =x;
     }
  // if(tp >0)
      takeprofit=tp;
 //  if(sl >0)
      stoploss=sl;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CalculateRiskStop(double lots)
  {
   double stopLevel = SymbolInfoInteger(Symbol(), SYMBOL_TRADE_STOPS_LEVEL);
   double tickvalue = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE);    //MarketInfo(Symbol(), MODE_TICKVALUE);

   double money = AccountInfoDouble(ACCOUNT_BALANCE);  // AccountBalance();
   if(money > MaxAccountValue && MaxAccountValue > 0)
      money = MaxAccountValue;

   double    MaxLossValue = money * Risk / 100;

   int sl_points = (int)(MaxLossValue / (lots * tickvalue)); //- spread);

   if(sl_points < stopLevel)
      sl_points = (int)stopLevel; // This may rise the risk over the reques

   return sl_points;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CalculateATR_SL(int shift)
  {
   int ret = 0;
   double stopLevel = SymbolInfoInteger(Symbol(), SYMBOL_TRADE_STOPS_LEVEL);
//  double tickvalue = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE);    //MarketInfo(Symbol(), MODE_TICKVALUE);


   double atrval = GetIndicatorValue(ATRPtr,shift); // iATR(NULL, 0, StopATRPeriod, shift);
   double diff = atrval * StopATRMultiplier;
   int sl_points = (int)(diff / Point());

   if(sl_points < stopLevel)
     {
      sl_points = (int)stopLevel; // This may rise the risk over the reques
     }
   if(ATRMaxStopLoss>0)
     {
      if(sl_points > ATRMaxStopLoss)
         sl_points=ATRMaxStopLoss;
     }
   ret = sl_points;

   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CalculateLastHILOStop(int mode, int shift)
  {
  double stopvalue = 0;
   double ret=0;
   int hilobar = 0;
   double stopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL);
   double tickvalue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double price = iOpen(NULL,0,shift);
   if(mode == OP_BUY)
     {
     // price = Ask;
      hilobar = iLowest(NULL, 0, MODE_LOW, HILOBackBars, shift + 1);
      stopvalue = iLow(NULL,0,hilobar);
      ret = MathAbs(price - stopvalue) / Point();
     }

   if(mode == OP_SELL)
     {
     // price=Bid;
      hilobar = iHighest(NULL, 0, MODE_HIGH, HILOBackBars, shift + 1);
      stopvalue = iHigh(NULL,0,hilobar);
      ret = MathAbs(stopvalue - price) / Point();
     }
   if(ret > MaxSL && MaxSL > 0)
      ret = MaxSL;
   if(ret < stopLevel)
      ret = (int)stopLevel; // This may rise the risk over the reques


//    Print(__FUNCTION__, ": StopLoss=", StopLoss);
   return ret;
  }
//+------------------------------------------------------------------+
