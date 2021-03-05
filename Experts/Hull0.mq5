//+------------------------------------------------------------------+
//|                                                        Hull1.mq5 |
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
#include <Expert\Signal\SignalHullMA.mqh>
#include <Expert\Signal\SignalITrendF.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingNone.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title          ="Hull1";     // Document name
ulong                    Expert_MagicNumber    =11609;       //
input bool                     Expert_EveryTick      =false;       //
//--- inputs for main signal
input int                Signal_ThresholdOpen  =10;          // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose =10;          // Signal threshold value to close [0...100]
input double             Signal_PriceLevel     =0.0;         // Price level to execute a deal
input double             Signal_StopLevel      =50.0;        // Stop Loss level (in points)
input double             Signal_TakeLevel      =50.0;        // Take Profit level (in points)
input int                Signal_Expiration     =4;           // Expiration of pending orders (in bars)
input int                Signal_HullMA_PeriodMA=12;          // Hull Moving Average(12,2.0,...) Period of averaging
input int                Signal_HullMA_Shift          =0;           // Hull Moving Average(12,2,...) Shift
input ENUM_APPLIED_PRICE Signal_HullMA_Applied =PRICE_CLOSE; // Hull Moving Average(12,2.0,...) Prices series
input double             Signal_HullMA_Weight  =1.0;         // Hull Moving Average(12,2.0,...) Weight [0...1.0]
input int                Signal_STF_TrendPeriod=50;          // SignalTrendFilter(50,...) Trend Period
 ENUM_MA_METHOD     Signal_STF_TrendMethod=MODE_SMA;    // SignalTrendFilter(50,...) Method of averaging
input int                Signal_STF_TrendMiniff=0;           // SignalTrendFilter(50,...) Trend Period min.Diff
input double             Signal_STF_Weight     =1.0;         // SignalTrendFilter(50,...) Weight [0...1.0]

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
//--- Creating filter CSignalHullMA
   CSignalHullMA *filter0=new CSignalHullMA;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.PeriodMA(Signal_HullMA_PeriodMA);
   filter0.Shift(Signal_HullMA_Shift);
   filter0.Applied(Signal_HullMA_Applied);
   filter0.Weight(Signal_HullMA_Weight);
//--- Creating filter CSignalITF
   CSignalTrend *filter1=new CSignalTrend;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.TrendPeriod(Signal_STF_TrendPeriod);
   filter1.TrendMindiff(Signal_STF_TrendMiniff);
   filter1.Weight(Signal_STF_Weight);
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
