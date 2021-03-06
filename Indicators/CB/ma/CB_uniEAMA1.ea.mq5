#define INDICATOR
#property strict
//--- indicator settings - cannot be included!!
#property indicator_chart_window
#property indicator_plots   8 //must set, can be bigger than necessary, can not be bigger than indicator_buffers
#property indicator_buffers 10 //must set, can be bigger than necessary
/*
#property indicator_color1 clrRed
#property indicator_width1 2
#property indicator_color2 clrBlue
#property indicator_width2 2
#property indicator_color3 clrRed
#property indicator_width3 2
#property indicator_color4 clrBlue
#property indicator_width4 2
#property indicator_color5 clrGreen
#property indicator_width5 2
#property indicator_color6 clrBrown
#property indicator_width6 1
*/
// SigBuy, SigSell
#property indicator_type7  DRAW_ARROW
#property indicator_color7 clrBlue
#property indicator_width7 1
#property indicator_type8  DRAW_ARROW
#property indicator_color8 clrRed
#property indicator_width8 1



//#define FILTER2

#define SIGNALS_MA
#define SIGNALS_SAR
#define SIGNALS_MACD
#define SIGNALS_STO

#define SIGNAL_SETTINGS
input  string SIGNAL_Settings = "--------  SIGNAL Settings -------------";
input  int BarRange=1;
input  int MinSignalScore=1;
input  string SIGSEL_Settings = "--------  SIGNAL Selection -------------";

input  int Signal1MATurn0=1;
input  int Signal1MATurn=0;
  int SignalSAR=0;
input  int Signal2MACross=0;
input  int Signal3MACross=0;
  int SignalMACD=0;
  int SignalSTO=0;
#define EXITSLTP
#define EXITRISC
#define EXITATR
#define EXITHILO


 
#include "..\..\..\Experts\cb\+uni\common\CB_Commons.mqh"
#include "..\..\..\Experts\cb\+uni\signals\CB_uniSignal.mqh";   
#include "..\..\..\Experts\cb\+uni\signals\CB_uniSignalLib.mqh"
#include "..\..\..\Experts\cb\+uni\common\CB_uniFilter1.mqh"
#include "..\..\..\Experts\cb\+uni\common\CB_CloseSignals.mqh";


#include "_uni\CB_UniIndicator.mqh"
