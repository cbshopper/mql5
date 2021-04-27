//+------------------------------------------------------------------+
//|                                                        test2.mq5 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#define SIGNALXL
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\CB\ExpertCB.mqh>

//--- available signals
#include <Expert\Signal\SignalDEMA.mqh>
#include <Expert\Signal\SignalTRIX.mqh>
#include <Expert\Signal\SignalAMA.mqh>
#include <Expert\Signal\SignalTEMA.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingMA.mqh>
#include <Expert\Trailing\TrailingNone.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>


//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title          ="MultiMa";     // Document name
ulong                    Expert_MagicNumber    =7270;        //
bool                     Expert_EveryTick      =false;       //
//--- inputs for main signal
input int                Signal_ThresholdOpen  =10;          // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose =10;          // Signal threshold value to close [0...100]
input double             Signal_PriceLevel     =0.0;         // Price level to execute a deal
input double             Signal_StopLevel      =50.0;        // Stop Loss level (in points)
input double             Signal_TakeLevel      =50.0;        // Take Profit level (in points)
#ifdef SIGNALXL
input double             Signal_VStopLevel      =50.0;        // VStop Loss level (in points)
input double             Signal_VTakeLevel      =50.0;        // VTake Profit level (in points)
input int                Signal_VDelayMinutes   =0;
input bool               Signal_VUse            = false;      // use VTAKE/VSTOP instead fo Take/Stop
#endif

input int                Signal_Expiration     =4;           // Expiration of pending orders (in bars)
input long               Signal_IgnoreBits     = 0;          // Igore Signal by setting corresponding bit

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input int                Signal_AMA_PeriodMA   =10;          // Adaptive Moving Average(10,...) Period of averaging
input int                Signal_AMA_PeriodFast =2;           // Adaptive Moving Average(10,...) Period of fast EMA
input int                Signal_AMA_PeriodSlow =30;          // Adaptive Moving Average(10,...) Period of slow EMA
int                Signal_AMA_Shift      =0;           // Adaptive Moving Average(10,...) Time shift
ENUM_APPLIED_PRICE Signal_AMA_Applied    =PRICE_CLOSE; // Adaptive Moving Average(10,...) Prices series
input double             Signal_AMA_Weight     =1.0;         // Adaptive Moving Average(10,...) Weight [0...1.0]

input int                Signal_DEMA_PeriodMA  =12;          // Double Exponential Moving Average Period of averaging
int                Signal_DEMA_Shift     =0;           // Double Exponential Moving Average Time shift
ENUM_APPLIED_PRICE Signal_DEMA_Applied   =PRICE_CLOSE; // Double Exponential Moving Average Prices series
input double             Signal_DEMA_Weight    =1.0;         // Double Exponential Moving Average Weight [0...1.0]
#ifdef ALL
input int                Signal_TriX_PeriodTriX=14;          // Triple Exponential Average Period of calculation
ENUM_APPLIED_PRICE Signal_TriX_Applied   =PRICE_CLOSE; // Triple Exponential Average Prices series
input double             Signal_TriX_Weight    =1.0;         // Triple Exponential Average Weight [0...1.0]



input int                Signal_TEMA_PeriodMA  =12;          // Triple Exponential Moving Average Period of averaging
int                Signal_TEMA_Shift     =0;           // Triple Exponential Moving Average Time shift
ENUM_APPLIED_PRICE Signal_TEMA_Applied   =PRICE_CLOSE; // Triple Exponential Moving Average Prices series
input double             Signal_TEMA_Weight    =1.0;         // Triple Exponential Moving Average Weight [0...1.0]
#endif
//--- inputs for trailing
/************
input int                Trailing_MA_Period     =12;               // Period of MA
input int                Trailing_MA_Shift      =0;                // Shift of MA
input ENUM_MA_METHOD     Trailing_MA_Method     =MODE_SMA;         // Method of averaging
input ENUM_APPLIED_PRICE Trailing_MA_Applied    =PRICE_CLOSE;      // Prices series
******/

//--- inputs for money
input double             Money_FixLot_Percent  =10.0;        // Percent
input double             Money_FixLot_Lots     =0.1;         // Fixed volume
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpertCB ExtExpert;
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
   CExpertSignalCB *signal=new CExpertSignalCB;
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
   signal.Ignore(Signal_IgnoreBits);
#ifdef SIGNALXL
   signal.VStopLevel(Signal_VStopLevel);
   signal.VTakeLevel(Signal_VTakeLevel);
   signal.VDelay(Signal_VDelayMinutes);
   signal.VUse(Signal_VUse);
#endif
//--- Creating filter CSignalAMA
   CSignalAMA *filter0=new CSignalAMA;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.PeriodMA(Signal_AMA_PeriodMA);
   filter0.PeriodFast(Signal_AMA_PeriodFast);
   filter0.PeriodSlow(Signal_AMA_PeriodSlow);
   filter0.Shift(Signal_AMA_Shift);
   filter0.Applied(Signal_AMA_Applied);
   filter0.Weight(Signal_AMA_Weight);
//--- Creating filter CSignalDEMA
   CSignalDEMA *filter2=new CSignalDEMA;
   if(filter2==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter2");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter2);
//--- Set filter parameters
   filter2.PeriodMA(Signal_DEMA_PeriodMA);
   filter2.Shift(Signal_DEMA_Shift);
   filter2.Applied(Signal_DEMA_Applied);
   filter2.Weight(Signal_DEMA_Weight);
#ifdef ALL   
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
   CSignalTEMA *filter4=new CSignalTEMA;
   if(filter4==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter4");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter4);
//--- Set filter parameters
   filter4.PeriodMA(Signal_TEMA_PeriodMA);
   filter4.Shift(Signal_TEMA_Shift);
   filter4.Applied(Signal_TEMA_Applied);
   filter4.Weight(Signal_TEMA_Weight);
#endif   
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
   /****************
   //--- Creation of trailing object
      CTrailingMA *trailing=new CTrailingMA;
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
      trailing.Period(Trailing_MA_Period);
      trailing.Shift(Trailing_MA_Shift);
      trailing.Method(Trailing_MA_Method);
      trailing.Applied(Trailing_MA_Applied);
    **************/
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
