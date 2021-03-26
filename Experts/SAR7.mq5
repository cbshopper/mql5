//+------------------------------------------------------------------+
//|                                                         SAR5.mq5 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\CB\ExpertCB.mqh>
//--- available signals
#include <Expert\Signal\SignalSAR.mqh>
#include <Expert\Signal\SignalSARChange.mqh>
#include <Expert\Signal\SignalMA.mqh>
#include <Expert\Signal\SignalITrendF.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingNone.mqh>

#include <Expert\Trailing\TrailingParabolicSAR.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>


//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string         Expert_Title                 ="SAR7";   // Document name
ulong                Expert_MagicNumber           =13930;    //
bool                 Expert_EveryTick             =false;    //
//--- inputs for main signal
input int            Signal_ThresholdOpen         =10;       // Signal threshold value to open [0...100]
input int            Signal_ThresholdClose        =10;       // Signal threshold value to close [0...100
input int            Signal_ThresholdExit        =10;       // Signal threshold value to exit [0...100]
input double         Signal_PriceLevel            =0.0;      // Price level to execute a deal
input double         Signal_StopLevel             =50.0;     // Stop Loss level (in points)
input double         Signal_TakeLevel             =50.0;     // Take Profit level (in points)
input int            Signal_Expiration            =4;        // Expiration of pending orders (in bars)
input int            Signal_VDelayMinutes   =0;
input bool           Signal_VUse            = false;      // use VTAKE/VSTOP instead fo Take/Stop
input int            Signal_MaxOrders           = 10;
input bool           Signal_AllowMultiOrders    = true;
input int            Signal_MinBarDiff          = 2;

input double         Signal_SAR_Step              =0.02;     // Parabolic SAR(0.02,0.2) Speed increment
input double         Signal_SAR_Maximum           =0.2;      // Parabolic SAR(0.02,0.2) Maximum rate
input double         Signal_SAR_Weight            =1.0;      // Parabolic SAR(0.02,0.2) Weight [0...1.0]
input int            Signal_STF_TrendPeriod       =50;       // SignalTrendFilter(50,...) Trend Period
input int            Signal_STF_TrendMiniff       =0;        // SignalTrendFilter(50,...) Trend Period min.Diff
 double         Signal_STF_Weight            =1.0;      // SignalTrendFilter(50,...) Weight [0...1.0]
 
input double         Exit_Signal_SAR_Step              =0.01;     //EXIT Parabolic SAR(0.02,0.2) Speed increment
input double         Exit_Signal_SAR_Maximum           =0.1;      //EXIT Parabolic SAR(0.02,0.2) Maximum rate
input double         Exit_Signal_SAR_ExitWeight        =1.0;      //EXIT Parabolic SAR(0.02,0.2) EXITWeight [0...1.0]
//
//input int                Exit_Signal_MA_PeriodMA    =12;          // EXIT Moving Average(12,0,...) Period of averaging
//input int                Exit_Signal_MA_Shift       =0;           // EXIT Moving Average(12,0,...) Time shift
//input ENUM_MA_METHOD     Exit_Signal_MA_Method      =MODE_SMA;    // EXIT Moving Average(12,0,...) Method of averaging
//input ENUM_APPLIED_PRICE Exit_Signal_MA_Applied     =PRICE_CLOSE; // EXIT Moving Average(12,0,...) Prices series
//input double             Exit_Signal_MA_ExitWeight      =1.0;         // EXIT Moving Average(12,0,...) EXITWeight [0...1.0]

//--- inputs for trailing
//input double         Trailing_ParabolicSAR_Step   =0.02;     // Speed increment
//input double         Trailing_ParabolicSAR_Maximum=0.2;      // Maximum rate
//--- inputs for money
input double         Money_FixLot_Percent         =10.0;     // Percent
input double         Money_FixLot_Lots            =0.1;      // Fixed volume


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
   ExtExpert.MultiOrderMode(Signal_AllowMultiOrders);
   ExtExpert.MaxOrders(Signal_MaxOrders);
   ExtExpert.MinBarDiff(Signal_MinBarDiff);
  
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
   signal.VStopLevel(Signal_StopLevel);
   signal.VTakeLevel(Signal_TakeLevel);
   signal.VDelay(Signal_VDelayMinutes);
   signal.VUse(Signal_VUse);
   signal.ThresholdExit(Signal_ThresholdExit);
//--- Creating filter CSignalSAR
  //CSignalSARChange *filter0=new CSignalSARChange;
   CSignalSAR *filter0=new CSignalSAR;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0,false);
//--- Set filter parameters
   filter0.Step(Signal_SAR_Step);
   filter0.Maximum(Signal_SAR_Maximum);
   filter0.Weight(Signal_SAR_Weight);
   /*
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
*/

//=======================================================================================

//--- Creating filter CSignalSAR FOR EXIT !!!!!
//   CSignalSARChange *filter2=new CSignalSARChange;
    CSignalSAR *filter2=new CSignalSAR;
   if(filter2==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter2");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter2,true);
//--- Set filter parameters
   filter2.Step(Exit_Signal_SAR_Step);
   filter2.Maximum(Exit_Signal_SAR_Maximum);
   filter2.Weight(0);
  // signal.SetAsExitSignal(filter2);
 
 //  CExpertSignalCB exit_filter = filter2; 
   // exit_filter.ExitWeight(Exit_Signal_SAR_ExitWeight);
  // signal.SetAsExitSignal(GetPointer(exit_filter));
 
  /*  
// -- Creating filter MA-Signal
   CSignalMA *filter3=new CSignalMA;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter3");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter3);
//--- Set filter parameters
   filter3.PeriodMA(Exit_Signal_MA_PeriodMA);
   filter3.Shift(Exit_Signal_MA_Shift);
   filter3.Method(Exit_Signal_MA_Method);
   filter3.Applied(Exit_Signal_MA_Applied);
   filter3.Weight(0);
  
   exit_filter = filter3; 
   exit_filter.ExitWeight(Exit_Signal_MA_ExitWeight);
   signal.SetAsExitSignal(GetPointer(exit_filter));
*/
//=======================================================================================
/*
//--- Creation of trailing object
   CTrailingPSAR *trailing=new CTrailingPSAR;
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
   trailing.Step(Trailing_ParabolicSAR_Step);
   trailing.Maximum(Trailing_ParabolicSAR_Maximum);
   */
//=======================================================================================
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
 //=======================================================================================

   
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
