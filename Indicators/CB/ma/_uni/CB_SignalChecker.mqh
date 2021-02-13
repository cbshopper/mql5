//+------------------------------------------------------------------+
//|                                                SignalChecker.mqh |
//|                                                   Christof blank |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Christof blank"
#property link      ""
//#property strict

#define SIGNALCHECKER_INLUDED

input string ___SIGNAL_CHECKER__ = "----------- Signal Checker -------------";
input bool                CheckSignals = true;
#ifdef INDICATOR
input double              Lots = 0.1;
#endif
input int                 maxbars = 10000;
input datetime            StartDate = 0;
input datetime            StopDate = 0;
#define BUTTON1_LABEL "Check"
#define BUTTON2_LABEL "Optimize"

#include <cb\CB_SLTPCalculator.mqh>
//#include "../../Experts/cb/+uni/common/CB_CloseSignals.mqh"

#include <cb\makeObjects.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//string Program = WindowExpertName();
double WinSum = 0;
int BuyWins = 0;
int BuyLoss = 0;
int SellWins = 0;
int SellLoss = 0;
int stopbar = 0;
int startbar = 0;



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShowButtons()
  {
   HideButtons();
   makeButton(BUTTON1_LABEL, BUTTON1_LABEL, 10, 20, 150, 20);
#ifdef OPTIMIZER_INCLUDED
   makeButton(BUTTON2_LABEL, BUTTON2_LABEL, 10, 45, 150, 20);
#endif

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HideButtons()
  {
   ObjectDelete(BUTTON1_LABEL);
   ObjectDelete(BUTTON2_LABEL);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ResultMsg()
  {
   string msg = "no exit settings!";
   if(CheckExitSettings())
     {
      string title = "SUM (WIN)";
      if(WinSum < 0)
         title = "SUM (LOSS)";
      msg = StringFormat("%s=%.2f, Wins=%d; Lost=%d (%d Bars, %s - %s)",
                         title,  WinSum, BuyWins + SellWins, BuyLoss + SellLoss,  startbar - stopbar, TimeToString(iTime(NULL,0,startbar)), TimeToString(iTime(NULL,0,stopbar)));
     }
   return msg;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckInit()
  {
//InitVars();
   WinSum = 0;
   BuyWins = 0;
   BuyLoss = 0;
   SellWins = 0;
   SellLoss = 0;
   int bar=0;
   if(StartDate > 0)
     {
      bar = iBarShift(NULL, 0, StartDate, false);
      if(bar > 0)
         startbar = bar;
      if(startbar > maxbars-1)
         startbar = maxbars-1;
     }
   else
     {
      startbar = MathMin(Bars-1, maxbars);
     }
   if(StopDate > 0)
     {
      bar = iBarShift(NULL, 0, StopDate, false);
      if(bar > 0)
         stopbar = bar;
     }
   else
     {
      stopbar = 0;
     }
   if(stopbar >= maxbars)
     {
      Comment("Wrong StopTime in SignalChecker!");
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double checkSignal(double &SigBuyArr[], double &SigSellArr[],int stoploss,int takeprofit,double lots,double crv,bool doDraw)
  {
   bool ok = CheckInit();
   if(!ok)
      return 0;
// Print(__FUNCTION__, " : START WinSum=", WinSum, " **************************************");
   for(int shift = startbar; shift >= stopbar; shift--)
     {
      //Buy-Signals
      if(SigBuyArr[shift] != 0)
         CheckWin(shift,OP_BUY,stoploss,takeprofit,lots,crv,doDraw);
      if(SigSellArr[shift] != 0)
         CheckWin(shift,OP_SELL,takeprofit,stoploss,lots,crv,doDraw);
     }

   return WinSum;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckWin(int shift, int mode,int stoploss, int takeprofit, double lots, double crv ,bool doDraw)
  {
   double val = iOpen(NULL,0,shift) ; //+ MarketInfo(NULL, MODE_SPREAD) * Point();
   double      win = 0;
   int direction=1;
   double     winval = 0;
   double     lossval = 0;

   if(mode == OP_BUY)
     {
      direction = 1;
     }
   if(mode == OP_SELL)
     {
      direction = -1;
     }

   CalculateTPSL(takeprofit,stoploss,lots,crv,mode,shift,takeprofit,stoploss);

   if(mode == OP_BUY)
     {
      if(takeprofit >0)
         winval = val + (MarketInfo(Symbol(), MODE_SPREAD)+takeprofit) * Point();
      if(stoploss > 0)
         lossval =  val - stoploss * Point();
     }
   if(mode == OP_SELL)
     {
      if(takeprofit >0)
         winval = val - (MarketInfo(Symbol(), MODE_SPREAD)+ takeprofit) * Point();
      if(stoploss > 0)
         lossval = val + stoploss * Point();
     }



   for(int i = shift - 1 ; i > 1; i--)
     {
      double         LVal = iLow(NULL,0,i);
      double        HVal = iHigh(NULL,0,i);
      bool is_loss=false;
      bool is_win=false;




      if(i < shift-1)
        {
         int close = GetCloseSignal4Tester(i,mode,iTime(NULL,0,shift), val);
          Print(__FUNCTION__,": i=",i, " close=",close, " Time=",iTime(NULL,0,i)," LVal=",LVal, " HVal=",HVal," winval=",winval," lossval=",lossval);
         if(close > 0)
           {
            if(mode == OP_BUY)
              {
               is_loss = iOpen(NULL,0,i) < val;
               is_win = iOpen(NULL,0,i) > val;
               if(is_loss)
                  lossval = iOpen(NULL,0,i);
               if(is_win)
                  winval = iOpen(NULL,0,i);
              }
            if(mode == OP_SELL)
              {
               is_loss = iOpen(NULL,0,i) > val;
               is_win = iOpen(NULL,0,i) < val;
               if(is_win)
                  winval =iOpen(NULL,0,i);
               if(is_loss)
                  lossval = iOpen(NULL,0,i);

              }
           }
         else
            if(close < 0)
              {
               if(lossval > 0 && winval > 0)
                 {
                  if(mode == OP_BUY)
                    {
                     is_loss = LVal <= lossval ;
                     is_win = HVal >= winval;
                    }
                  if(mode == OP_SELL)
                    {
                     is_loss = HVal >= lossval;
                     is_win =  LVal <= winval ;
                    }
                 }
              }
        }

      if(is_loss && i > 0)
        {
         if(mode == OP_BUY)
            BuyLoss++;
         if(mode == OP_SELL)
            SellLoss++;
         win = CalcAndDraw(shift, i, val, lossval, direction,lots,doDraw);
         break;
        }
      if(is_win && i > 0)
        {
         if(mode == OP_BUY)
            BuyWins++;
         if(mode == OP_SELL)
            SellWins++;
         win = CalcAndDraw(shift, i, val, winval, direction,lots,doDraw);
         break;
        }
     }
   WinSum += win;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  CalcAndDraw(int startbar, int stopbar, double startval, double stopval, int signal,double lots, bool doDraw)
  {
   string ret = "";
   double win = 0;
   int width = 3;

   if(startbar > 0)
     {
      color clr = clrDarkGreen;
      string prefix = "WIN!";
      if(signal == 1)
        {
         win = stopval - startval;
        }
      if(signal == -1)
        {
         win = startval - stopval;
        }
      if(win < 0)
        {
         clr = clrDarkGoldenrod;
         prefix = "LOST!";
         //  width = 3;
        }
      int pips = (int)(win / Point());

      //win = NormalizeDouble(win, Digits);
      // win = (pips - MarketInfo(Symbol(), MODE_SPREAD)) * Lots * TickValue(Symbol()); //PipValue(Symbol()) ;
      win = (pips) * lots * TickValue(Symbol());  //PipValue(Symbol()) ;

      if(doDraw)
        {
         //string name=StringFormat("LINE %d to %d (%d) %s",startbar,stopbar,pips,prefix);
         string text = StringFormat("%s-%s\nP=%d W=%2." + Digits() + "f S=%2." + Digits() + "f\n",
                                    TimeToString(iTime(NULL,0,startbar)),
                                    TimeToString(iTime(NULL,0,stopbar)),
                                    pips,
                                    win,
                                    WinSum);
         int index = startbar;
         ret = TLine(index, MQLInfoString(MQL_PROGRAM_NAME), text, iTime(NULL,0,startbar), startval, iTime(NULL,0,stopbar), stopval, clr, width);
        }
      //Print(__FUNCTION__, ": ", text);
      /*
            string TLine(int index,string text,string postfix, datetime T0,double P0,datetime T1,double P1
                   ,color clr,bool asLine=false,bool ray=false,int offset=0,int width=3)
                   */
     }
   return win;
  }

#define WINDOW_MAIN 0
string TLine(int index, string prefix, string text, datetime T0, double P0, datetime T1, double P1, color clr, int width)
  {
   string name = prefix + " " + (string) index;
//  Print(__FUNCTION__," name=",name," P0=",P0," P1=",P1, " T0=",T0, " T1=",T1);

   if(ObjectFind(WINDOW_MAIN, name) > -1)
     {
      ObjectDelete(WINDOW_MAIN, name);
     }


   if(!ObjectCreate(WINDOW_MAIN,name, OBJ_TREND, WINDOW_MAIN, T0, P0, T1, P1))
     {
      Alert("ObjectCreate(", name, ",TREND) failed: ", GetLastError());
     }
   else
     {
      if(!ObjectSetInteger(WINDOW_MAIN,name, OBJPROP_RAY, (long)false))
        {
         Alert("ObjectSet(", name, ",Ray) failed: ", GetLastError());
        }
     }
   if(!ObjectSetInteger(WINDOW_MAIN,name, OBJPROP_WIDTH, width))
     {
      Alert("ObjectSet(", name, ",OBJPROP_WIDTH) failed: ", GetLastError());
     }
   if(!ObjectSetInteger(WINDOW_MAIN,name, OBJPROP_STYLE, STYLE_DOT))
     {
      Alert("ObjectSet(", name, ",OBJPROP_STYLE) failed: ", GetLastError());
     }
   if(!ObjectSetInteger(WINDOW_MAIN,name, OBJPROP_COLOR, clr)) // Allow color change
      Alert("ObjectSet(", name, ",Color) [2] failed: ", GetLastError());


   if(!ObjectSetString(WINDOW_MAIN,name,OBJPROP_TEXT, text))
      Alert("ObjectSetText(", name, ") [2] failed: ", GetLastError());
   return name;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClearLines()
  {
   ObjectsDeleteAll(0, MQLInfoString(MQL_PROGRAM_NAME));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#ifndef ONCHARTEVENT
void OnChartEvent(const int id,         // Event ID
                  const long& lparam,   // Parameter of type long event
                  const double& dparam, // Parameter of type double event
                  const string& sparam  // Parameter of type string events
                 )
  {
   onChartEvent(id,lparam,dparam,sparam);
  }
#endif
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void onChartEvent(const int id,         // Event ID
                  const long& lparam,   // Parameter of type long event
                  const double& dparam, // Parameter of type double event
                  const string& sparam  // Parameter of type string events
                 )
  {
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam == BUTTON1_LABEL)
        {
         ClearLines();
         //   string msg = ParameterInfo();
         //  calculate(Bars, 0);
         string msg = "";
         
         CheckSignal(true);
         setButtonPressed(BUTTON1_LABEL, false);
        }
      if(sparam == BUTTON2_LABEL)
        {
         ClearLines();
#ifdef OPTIMIZER_INCLUDED
         OptimizeSignals();
#endif


         setButtonPressed(BUTTON2_LABEL, false);
        }
     }
  }

//+------------------------------------------------------------------+
