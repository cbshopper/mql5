//+------------------------------------------------------------------+
//|                                                 CB_Validator.mqh |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Christof Blank"
#property link      "https://www.???.???"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

#include <CB/CB_Drawing.mqh>
input int ValidateTimeDays = 30;
input int Offset = 1;


double         SellSignalOpenBuffer[];
double         BuySignalOpenBuffer[];
double         SellSignalCloseBuffer[];
double         BuySignalCloseBuffer[];
double total_win = 0;
int total_pips = 0;
int total_tradecount = 0;
int total_wincnt = 0, total_losscnt = 0;
string         Program = "VALIDATOR";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int InitSignalBuffers()
  {
   int buffercount = 4;
//** BUFFERS for Validator
//--- indicator buffers mapping
   SetIndexBuffer(0, BuySignalOpenBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, SellSignalOpenBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, BuySignalCloseBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, SellSignalCloseBuffer, INDICATOR_DATA);
//--- Define the symbol code for drawing in PLOT_ARROW
   PlotIndexSetInteger(0, PLOT_ARROW, 233);
   PlotIndexSetInteger(1, PLOT_ARROW, 234);
   PlotIndexSetInteger(2, PLOT_ARROW, 170);
   PlotIndexSetInteger(3, PLOT_ARROW, 170);
//--- Set the vertical shift of arrows in pixels
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 25);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -25);
   PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, -50);
   PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, 50);
//--- Set as an empty value 0
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);
//--- setting the arrays in timeseries
   ArraySetAsSeries(BuySignalOpenBuffer, true);
   ArraySetAsSeries(SellSignalOpenBuffer, true);
   ArraySetAsSeries(BuySignalCloseBuffer, true);
   ArraySetAsSeries(SellSignalCloseBuffer, true);
   ArrayInitialize(BuySignalOpenBuffer, EMPTY_VALUE);
   ArrayInitialize(SellSignalOpenBuffer, EMPTY_VALUE);
   ArrayInitialize(BuySignalCloseBuffer, EMPTY_VALUE);
   ArrayInitialize(SellSignalCloseBuffer, EMPTY_VALUE);
//---
   DeleteTLines();
   total_win = 0;
   total_pips = 0;
   total_tradecount = 0;
   total_wincnt = 0;
   total_losscnt = 0;
   return(buffercount);
  }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawOrderLines()
  {
  
   total_win = 0;
   total_pips = 0;
   total_tradecount = 0;
   total_wincnt = 0;
   total_losscnt = 0;
   int startshift = 0;
   
   if(ValidateTimeDays > 0)
     {
       startshift = ValidateTimeDays * 24 * 60 * 60 / PeriodSeconds();
     }
     else
     {
        return;
     }
   
   if(startshift > ArraySize(BuySignalOpenBuffer))
     {
      startshift = ArraySize(BuySignalOpenBuffer) - 1;
     }
     
   for(int shift = startshift; shift > 0; shift--)
     {
      if(BuySignalOpenBuffer[shift] != EMPTY_VALUE)
        {
         FindClose(shift, BuySignalCloseBuffer, 1);
         /*
          int startbar = shift - Offset;
          for(int i = shift - 1; i > 0 ; i --)
            {
             if(BuySignalCloseBuffer[i] != EMPTY_VALUE || i == 0)
               {
                DrawLine(1, startbar, i);
                break;
               }
            }
            */
        }
      if(SellSignalOpenBuffer[shift] != EMPTY_VALUE)
        {
         FindClose(shift, SellSignalCloseBuffer, -1);
         /*
          int startbar = shift - Offset;
          for(int i = shift - 1; i > 0; i --)
            {
             if(SellSignalCloseBuffer[i] != EMPTY_VALUE || i == 0)
               {
                DrawLine(-1, startbar, i);
                break;
               }
            }
            */
        }
     }
   Comment(StringFormat("Result from %s: Pips=%d, Win/Loss=%f, Trades=%d (win=%d,,loss=%d)", TimeToString(iTime(NULL, 0, startshift)), total_pips, total_win, total_tradecount, total_wincnt, total_losscnt));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FindClose(int shift, double &valArr[], int signal)
  {
   int startbar = shift - Offset;
   for(int i = shift ; i > 0; i --)
     {
      if(valArr[i] != EMPTY_VALUE) // || i == 0)
        {
         DrawLine(signal, startbar, i);
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLine(int signal,  int startbar, int stopbar)
  {
   double winval = 0;
   int pips = 0;
   stopbar = stopbar - Offset;
   if(stopbar  <= 0)
      stopbar = 1;
   pips = CalcOrderResultValues(startbar, stopbar, signal, winval);
   DrawOrderLine(startbar, stopbar, pips, winval, 0, 3);
   total_win += winval;
   total_pips += pips;
   if(winval > 0)
      total_wincnt++;
   else
      total_losscnt++;
   total_tradecount++;
  }
//+------------------------------------------------------------------+
