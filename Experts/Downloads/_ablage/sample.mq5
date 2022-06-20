//+------------------------------------------------------------------+
//|                                                       Sample.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\SignalMA.mqh>
#include <Expert\Signal\SignalStoch.mqh>
#include <Expert\Signal\SignalITF.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingNone.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title             ="Sample";    // Document name
int                      Expert_MagicNumber       =27919;       // 
bool                     Expert_EveryTick         =false;       // 
//--- inputs for main signal
input int                Signal_ThresholdOpen     =0;           // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose    =0.0;         // Signal threshold value to close [0...100]
input double             Signal_PriceLevel        =0.0;         // Price level to execute a deal
input double             Signal_StopLevel         =500.0;       // Stop Loss level (in points)
input double             Signal_TakeLevel         =200.0;       // Take Profit level (in points)
input int                Signal_Expiration        =4;           // Expiration of pending orders (in bars)
input double             Signal_0_MA_Weight       =1.0;         // Moving Average(31,0,MODE_EMA) Weight [0...1.0]
input double             Signal_0_Stoch_Weight    =1.0;         // Stochastic(8,3,3,STO_LOWHIGH) Weight [0...1.0]
input double             Signal_1_MA_Weight       =1.0;         // Moving Average(24,0,MODE_EMA) H1 Weight [0...1.0]
input double             Signal_1_Stoch_Weight    =1.0;         // Stochastic(8,3,3,STO_LOWHIGH) H4 EURJPY Weight [0...1.0]
input int                Signal_ITF_GoodHourOfDay =-1;          // IntradayTimeFilter(-1,0,-1,0) Good hour
input int                Signal_ITF_BadHoursOfDay =0;           // IntradayTimeFilter(-1,0,-1,0) Bad hours (bit-map)
input int                Signal_ITF_GoodDayOfWeek =-1;          // IntradayTimeFilter(-1,0,-1,0) Good day of week
input int                Signal_ITF_BadDaysOfWeek =0;           // IntradayTimeFilter(-1,0,-1,0) Bad days of week (bit-map)
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
   if(!ExtExpert.Init("EURUSD",PERIOD_M10,Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(-1);
     }
//--- Get pointer on experts signal
   CExpertSignal *signal=ExtExpert.Signal();
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(-2);
     }
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
      return(-3);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.PeriodMA(31);
   filter0.Method(MODE_EMA);
   filter0.Weight(Signal_0_MA_Weight);
//--- Creating filter CSignalStoch
   CSignalStoch *filter1=new CSignalStoch;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(-4);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.Weight(Signal_0_Stoch_Weight);
//--- Creating filter CSignalMA
   CSignalMA *filter2=new CSignalMA;
   if(filter2==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter2");
      ExtExpert.Deinit();
      return(-5);
     }
   signal.AddFilter(filter2);
//--- Set filter parameters
   filter2.Period(PERIOD_H1);
   filter2.PeriodMA(24);
   filter2.Method(MODE_EMA);
   filter2.Weight(Signal_1_MA_Weight);
//--- Creating filter CSignalStoch
   CSignalStoch *filter3=new CSignalStoch;
   if(filter3==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter3");
      ExtExpert.Deinit();
      return(-6);
     }
   signal.AddFilter(filter3);
//--- Set filter parameters
   filter3.Symbol("EURJPY");
   filter3.Period(PERIOD_H4);
   filter3.Weight(Signal_1_Stoch_Weight);
//--- Creating filter CSignalITF
   CSignalITF *filter4=new CSignalITF;
   if(filter4==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter4");
      ExtExpert.Deinit();
      return(-7);
     }
   signal.AddFilter(filter4);
//--- Set filter parameters
   filter4.GoodHourOfDay(Signal_ITF_GoodHourOfDay);
   filter4.BadHoursOfDay(Signal_ITF_BadHoursOfDay);
   filter4.GoodDayOfWeek(Signal_ITF_GoodDayOfWeek);
   filter4.BadDaysOfWeek(Signal_ITF_BadDaysOfWeek);
//--- Creation of trailing object
   CTrailingNone *trailing=new CTrailingNone;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(-8);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(-9);
     }
//--- Set trailing parameters
//--- Creation of money object
   CMoneyFixedLot *money=new CMoneyFixedLot;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(-10);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(-11);
     }
//--- Set money parameters
//--- Check all trading objects parameters
   if(!ExtExpert.ValidationSettings())
     {
      //--- failed
      ExtExpert.Deinit();
      return(-12);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(-13);
     }
//--- ok
   return(0);
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
