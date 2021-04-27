//+------------------------------------------------------------------+
//|                                                         3EMA.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\Signal3MA.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingMA.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title         ="3EMA";      // Document name
ulong                    Expert_MagicNumber   =17535;       //
bool                     Expert_EveryTick     =false;       //
//--- inputs for main signal
input int                Signal_ThresholdOpen =10;          // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose=10;          // Signal threshold value to close [0...100]
input double             Signal_PriceLevel    =0.0;         // Price level to execute a deal
input double             Signal_StopLevel     =50.0;        // Stop Loss level (in points)
input double             Signal_TakeLevel     =50.0;        // Take Profit level (in points)
input int                Signal_Expiration    =4;           // Expiration of pending orders (in bars)
input int                Signal_3EMA_Period0  =21;          // 3MA(21,34,50,MODE_SMA,...) Period of averaging 0
input int                Signal_3EMA_Period1  =34;          // 3MA(21,34,50,MODE_SMA,...) Period of averaging 1
input int                Signal_3EMA_Period2  =50;          // 3MA(21,34,50,MODE_SMA,...) Period of averaging 2
input ENUM_MA_METHOD     Signal_3EMA_Method   =MODE_SMA;    // 3MA(21,34,50,MODE_SMA,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_3EMA_Applied  =PRICE_CLOSE; // 3MA(21,34,50,MODE_SMA,...) Prices series
input int                Signal_3EMA_Offset   = 3;          // 3MA Shift Offset of previous MA
input bool               Signal_3EMA_UseMACross = false;    // Use Cross of MA2 as Signal
input int                Signal_3EMA_MinDiff = 1;           // min. Diff of MA2


input double             Signal_3EMA_Weight   =1.0;         // 3MA(21,34,50,MODE_SMA,...) Weight [0...1.0]

//--- inputs for trailing
input int                Trailing_HMA_Period  =34;          // Period of MA
input int                Trailing_HMA_Shift   =0;           // Shift of MA
input ENUM_MA_METHOD     Trailing_HMA_Method  =MODE_EMA;    // Method of averaging
input ENUM_APPLIED_PRICE Trailing_HMA_Applied =PRICE_CLOSE; // Prices series
//--- inputs for money
input double             Money_FixLot_Percent =10.0;        // Percent
input double             Money_FixLot_Lots    =0.1;         // Fixed volume
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
//--- Creating filter CSignal3MA
   CSignal3MA *filter0=new CSignal3MA;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.Period0(Signal_3EMA_Period0);
   filter0.Period1(Signal_3EMA_Period1);
   filter0.Period2(Signal_3EMA_Period2);
   filter0.Method(Signal_3EMA_Method);
   filter0.Applied(Signal_3EMA_Applied);
   filter0.UseMACross(Signal_3EMA_UseMACross);
   filter0.MinDiff(Signal_3EMA_MinDiff);
   filter0.Offset(Signal_3EMA_Offset);   
   filter0.Weight(Signal_3EMA_Weight);
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
   trailing.Period(Trailing_HMA_Period);
   trailing.Shift(Trailing_HMA_Shift);
   trailing.Method(Trailing_HMA_Method);
   trailing.Applied(Trailing_HMA_Applied);
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
