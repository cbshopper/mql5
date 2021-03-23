//+------------------------------------------------------------------+
//|                                                           MA.mq5 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\SignalMA.mqh>
#include <Expert\Signal\SignalTRIX.mqh>
#include <Expert\Signal\SignalTEMA.mqh>
#include <Expert\Signal\SignalAMA.mqh>
#include <Expert\Signal\SignalDEMA.mqh>
#include <Expert\Signal\SignalFrAMA.mqh>
#include <Expert\Signal\SignalHullMA2.mqh.bak>
//--- available trailing
#include <Expert\Trailing\TrailingNone.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title          ="MA";        // Document name
ulong                    Expert_MagicNumber    =25280;       //
bool                     Expert_EveryTick      =false;       //
//--- inputs for main signal
input int                Signal_ThresholdOpen  =10;          // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose =10;          // Signal threshold value to close [0...100]
input double             Signal_PriceLevel     =0.0;         // Price level to execute a deal
input double             Signal_StopLevel      =50.0;        // Stop Loss level (in points)
input double             Signal_TakeLevel      =50.0;        // Take Profit level (in points)
input int                Signal_Expiration     =4;           // Expiration of pending orders (in bars)
input int                Signal_MA_PeriodMA    =12;          // Moving Average(12,0,...) Period of averaging
input int                Signal_MA_Shift       =0;           // Moving Average(12,0,...) Time shift
input ENUM_MA_METHOD     Signal_MA_Method      =MODE_SMA;    // Moving Average(12,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_MA_Applied     =PRICE_CLOSE; // Moving Average(12,0,...) Prices series
input double             Signal_MA_Weight      =1.0;         // Moving Average(12,0,...) Weight [0...1.0]
input int                Signal_TriX_PeriodTriX=14;          // Triple Exponential Average Period of calculation
input ENUM_APPLIED_PRICE Signal_TriX_Applied   =PRICE_CLOSE; // Triple Exponential Average Prices series
input double             Signal_TriX_Weight    =1.0;         // Triple Exponential Average Weight [0...1.0]
input int                Signal_TEMA_PeriodMA  =12;          // Triple Exponential Moving Average Period of averaging
input int                Signal_TEMA_Shift     =0;           // Triple Exponential Moving Average Time shift
input ENUM_APPLIED_PRICE Signal_TEMA_Applied   =PRICE_CLOSE; // Triple Exponential Moving Average Prices series
input double             Signal_TEMA_Weight    =1.0;         // Triple Exponential Moving Average Weight [0...1.0]
input int                Signal_AMA_PeriodMA   =10;          // Adaptive Moving Average(10,...) Period of averaging
input int                Signal_AMA_PeriodFast =2;           // Adaptive Moving Average(10,...) Period of fast EMA
input int                Signal_AMA_PeriodSlow =30;          // Adaptive Moving Average(10,...) Period of slow EMA
input int                Signal_AMA_Shift      =0;           // Adaptive Moving Average(10,...) Time shift
input ENUM_APPLIED_PRICE Signal_AMA_Applied    =PRICE_CLOSE; // Adaptive Moving Average(10,...) Prices series
input double             Signal_AMA_Weight     =1.0;         // Adaptive Moving Average(10,...) Weight [0...1.0]
input int                Signal_DEMA_PeriodMA  =12;          // Double Exponential Moving Average Period of averaging
input int                Signal_DEMA_Shift     =0;           // Double Exponential Moving Average Time shift
input ENUM_APPLIED_PRICE Signal_DEMA_Applied   =PRICE_CLOSE; // Double Exponential Moving Average Prices series
input double             Signal_DEMA_Weight    =1.0;         // Double Exponential Moving Average Weight [0...1.0]
input int                Signal_FraMA_PeriodMA =12;          // Fractal Adaptive Moving Average Period of averaging
input int                Signal_FraMA_Shift    =0;           // Fractal Adaptive Moving Average Time shift
input ENUM_APPLIED_PRICE Signal_FraMA_Applied  =PRICE_CLOSE; // Fractal Adaptive Moving Average Prices series
input double             Signal_FraMA_Weight   =1.0;         // Fractal Adaptive Moving Average Weight [0...1.0]
input int                Signal_HullMA_PeriodMA=12;          // Hull Moving Average(12,2.0,...) Period of averaging
input double             Signal_HullMA_Divisor =2.0;         // Hull Moving Average(12,2.0,...) Hull Divisor
input ENUM_APPLIED_PRICE Signal_HullMA_Applied =PRICE_CLOSE; // Hull Moving Average(12,2.0,...) Prices series
input double             Signal_HullMA_Weight  =1.0;         // Hull Moving Average(12,2.0,...) Weight [0...1.0]
//--- inputs for money
input double             Money_FixLot_Percent  =10.0;        // Percent
input double             Money_FixLot_Lots     =0.1;         // Fixed volume
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Creating signal
   CExpertSignal *signal=new CExpertSignal;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ExtExpert.InitSignal(signal);
   signal.ThresholdOpen(Signal_ThresholdOpen);
   signal.ThresholdClose(Signal_ThresholdClose);
   signal.PriceLevel(Signal_PriceLevel);
   signal.StopLevel(Signal_StopLevel);
   signal.TakeLevel(Signal_TakeLevel);
   signal.Expiration(Signal_Expiration);
//--- Creating filter CSignalMA
   CSignalMA *filter0=new CSignalMA;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.PeriodMA(Signal_MA_PeriodMA);
   filter0.Shift(Signal_MA_Shift);
   filter0.Method(Signal_MA_Method);
   filter0.Applied(Signal_MA_Applied);
   filter0.Weight(Signal_MA_Weight);
//--- Creating filter CSignalTriX
   CSignalTriX *filter1=new CSignalTriX;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.PeriodTriX(Signal_TriX_PeriodTriX);
   filter1.Applied(Signal_TriX_Applied);
   filter1.Weight(Signal_TriX_Weight);
//--- Creating filter CSignalTEMA
   CSignalTEMA *filter2=new CSignalTEMA;
   if(filter2==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter2");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter2);
//--- Set filter parameters
   filter2.PeriodMA(Signal_TEMA_PeriodMA);
   filter2.Shift(Signal_TEMA_Shift);
   filter2.Applied(Signal_TEMA_Applied);
   filter2.Weight(Signal_TEMA_Weight);
//--- Creating filter CSignalAMA
   CSignalAMA *filter3=new CSignalAMA;
   if(filter3==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter3");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter3);
//--- Set filter parameters
   filter3.PeriodMA(Signal_AMA_PeriodMA);
   filter3.PeriodFast(Signal_AMA_PeriodFast);
   filter3.PeriodSlow(Signal_AMA_PeriodSlow);
   filter3.Shift(Signal_AMA_Shift);
   filter3.Applied(Signal_AMA_Applied);
   filter3.Weight(Signal_AMA_Weight);
//--- Creating filter CSignalDEMA
   CSignalDEMA *filter4=new CSignalDEMA;
   if(filter4==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter4");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter4);
//--- Set filter parameters
   filter4.PeriodMA(Signal_DEMA_PeriodMA);
   filter4.Shift(Signal_DEMA_Shift);
   filter4.Applied(Signal_DEMA_Applied);
   filter4.Weight(Signal_DEMA_Weight);
//--- Creating filter CSignalFrAMA
   CSignalFrAMA *filter5=new CSignalFrAMA;
   if(filter5==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter5");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter5);
//--- Set filter parameters
   filter5.PeriodMA(Signal_FraMA_PeriodMA);
   filter5.Shift(Signal_FraMA_Shift);
   filter5.Applied(Signal_FraMA_Applied);
   filter5.Weight(Signal_FraMA_Weight);
//--- Creating filter CSignalHullMA2
   CSignalHullMA2 *filter6=new CSignalHullMA2;
   if(filter6==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter6");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter6);
//--- Set filter parameters
   filter6.PeriodMA(Signal_HullMA_PeriodMA);
   filter6.Divisor(Signal_HullMA_Divisor);
   filter6.Applied(Signal_HullMA_Applied);
   filter6.Weight(Signal_HullMA_Weight);
//--- Creation of trailing object
   CTrailingNone *trailing=new CTrailingNone;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set trailing parameters
//--- Creation of money object
   CMoneyFixedLot *money=new CMoneyFixedLot;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set money parameters
   money.Percent(Money_FixLot_Percent);
   money.Lots(Money_FixLot_Lots);
//--- Check all trading objects parameters
   if(!ExtExpert.ValidationSettings())
     {
      //--- failed
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
