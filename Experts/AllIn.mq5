//+------------------------------------------------------------------+
//|                                                        AllIn.mq5 |
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
#include <Expert\Signal\SignalAC.mqh>
#include <Expert\Signal\SignalAMA.mqh>
#include <Expert\Signal\SignalAO.mqh>
#include <Expert\Signal\SignalBearsPower.mqh>
#include <Expert\Signal\SignalBullsPower.mqh>
#include <Expert\Signal\SignalCCI.mqh>
#include <Expert\Signal\SignalDeMarker.mqh>
#include <Expert\Signal\SignalDEMA.mqh>
#include <Expert\Signal\SignalEnvelopes.mqh>
#include <Expert\Signal\SignalFrAMA.mqh>
#include <Expert\Signal\SignalMACD.mqh>
#include <Expert\Signal\SignalMA.mqh>
#include <Expert\Signal\SignalSAR.mqh>
#include <Expert\Signal\SignalRSI.mqh>
#include <Expert\Signal\SignalRVI.mqh>
#include <Expert\Signal\SignalStoch.mqh>
#include <Expert\Signal\SignalTRIX.mqh>
#include <Expert\Signal\SignalTEMA.mqh>
#include <Expert\Signal\SignalWPR.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingNone.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title                 ="AllIn";     // Document name
ulong                    Expert_MagicNumber           =251;         //
bool                     Expert_EveryTick             =false;       //
//--- inputs for main signal
input int                Signal_ThresholdOpen         =10;          // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose        =10;          // Signal threshold value to close [0...100]
input double             Signal_PriceLevel            =0.0;         // Price level to execute a deal
input double             Signal_StopLevel             =50.0;        // Stop Loss level (in points)
input double             Signal_TakeLevel             =50.0;        // Take Profit level (in points)
input int                Signal_Expiration            =4;           // Expiration of pending orders (in bars)

input double             Signal_AC_Weight             =1.0;         // Accelerator Oscillator Weight [0...1.0]

input int                Signal_AMA_PeriodMA          =10;          // Adaptive Moving Average(10,...) Period of averaging
input int                Signal_AMA_PeriodFast        =2;           // Adaptive Moving Average(10,...) Period of fast EMA
input int                Signal_AMA_PeriodSlow        =30;          // Adaptive Moving Average(10,...) Period of slow EMA
 int                Signal_AMA_Shift             =0;           // Adaptive Moving Average(10,...) Time shift
 ENUM_APPLIED_PRICE Signal_AMA_Applied           =PRICE_CLOSE; // Adaptive Moving Average(10,...) Prices series

input double             Signal_AMA_Weight            =1.0;         // Adaptive Moving Average(10,...) Weight [0...1.0]
input double             Signal_AO_Weight             =1.0;         // Awesome Oscillator Weight [0...1.0]
input int                Signal_BearsPower_PeriodBears=13;          // Bears Power(13) Period of calculation
input double             Signal_BearsPower_Weight     =1.0;         // Bears Power(13) Weight [0...1.0]
input int                Signal_BullsPower_PeriodBulls=13;          // Bulls Power(13) Period of calculation
input double             Signal_BullsPower_Weight     =1.0;         // Bulls Power(13) Weight [0...1.0]

input int                Signal_CCI_PeriodCCI         =8;           // Commodity Channel Index(8,...) Period of calculation
 ENUM_APPLIED_PRICE Signal_CCI_Applied           =PRICE_CLOSE; // Commodity Channel Index(8,...) Prices series
input double             Signal_CCI_Weight            =1.0;         // Commodity Channel Index(8,...) Weight [0...1.0]

input int                Signal_DeM_PeriodDeM         =8;           // DeMarker(8) Period of calculation
input double             Signal_DeM_Weight            =1.0;         // DeMarker(8) Weight [0...1.0]

input int                Signal_DEMA_PeriodMA         =12;          // Double Exponential Moving Average Period of averaging
 int                Signal_DEMA_Shift            =0;           // Double Exponential Moving Average Time shift
 ENUM_APPLIED_PRICE Signal_DEMA_Applied          =PRICE_CLOSE; // Double Exponential Moving Average Prices series
input double             Signal_DEMA_Weight           =1.0;         // Double Exponential Moving Average Weight [0...1.0]

input int                Signal_Envelopes_PeriodMA    =45;          // Envelopes(45,0,MODE_SMA,...) Period of averaging
 int                Signal_Envelopes_Shift       =0;           // Envelopes(45,0,MODE_SMA,...) Time shift
input ENUM_MA_METHOD     Signal_Envelopes_Method      =MODE_SMA;    // Envelopes(45,0,MODE_SMA,...) Method of averaging
 ENUM_APPLIED_PRICE Signal_Envelopes_Applied     =PRICE_CLOSE; // Envelopes(45,0,MODE_SMA,...) Prices series
input double             Signal_Envelopes_Deviation   =0.15;        // Envelopes(45,0,MODE_SMA,...) Deviation
input double             Signal_Envelopes_Weight      =1.0;         // Envelopes(45,0,MODE_SMA,...) Weight [0...1.0]

input int                Signal_FraMA_PeriodMA        =12;          // Fractal Adaptive Moving Average Period of averaging
 int                Signal_FraMA_Shift           =0;           // Fractal Adaptive Moving Average Time shift
 ENUM_APPLIED_PRICE Signal_FraMA_Applied         =PRICE_CLOSE; // Fractal Adaptive Moving Average Prices series
input double             Signal_FraMA_Weight          =1.0;         // Fractal Adaptive Moving Average Weight [0...1.0]

input int                Signal_MACD_PeriodFast       =12;          // MACD(12,24,9,PRICE_CLOSE) Period of fast EMA
input int                Signal_MACD_PeriodSlow       =24;          // MACD(12,24,9,PRICE_CLOSE) Period of slow EMA
input int                Signal_MACD_PeriodSignal     =9;           // MACD(12,24,9,PRICE_CLOSE) Period of averaging of difference
 ENUM_APPLIED_PRICE Signal_MACD_Applied          =PRICE_CLOSE; // MACD(12,24,9,PRICE_CLOSE) Prices series
input double             Signal_MACD_Weight           =1.0;         // MACD(12,24,9,PRICE_CLOSE) Weight [0...1.0]

input int                Signal_MA_PeriodMA           =12;          // Moving Average(12,0,...) Period of averaging
 int                Signal_MA_Shift              =0;           // Moving Average(12,0,...) Time shift
input ENUM_MA_METHOD     Signal_MA_Method             =MODE_SMA;    // Moving Average(12,0,...) Method of averaging
 ENUM_APPLIED_PRICE Signal_MA_Applied            =PRICE_CLOSE; // Moving Average(12,0,...) Prices series
input double             Signal_MA_Weight             =1.0;         // Moving Average(12,0,...) Weight [0...1.0]

input double             Signal_SAR_Step              =0.02;        // Parabolic SAR(0.02,0.2) Speed increment
input double             Signal_SAR_Maximum           =0.2;         // Parabolic SAR(0.02,0.2) Maximum rate
input double             Signal_SAR_Weight            =1.0;         // Parabolic SAR(0.02,0.2) Weight [0...1.0]

input int                Signal_RSI_PeriodRSI         =8;           // Relative Strength Index(8,...) Period of calculation
 ENUM_APPLIED_PRICE Signal_RSI_Applied           =PRICE_CLOSE; // Relative Strength Index(8,...) Prices series
input double             Signal_RSI_Weight            =1.0;         // Relative Strength Index(8,...) Weight [0...1.0]
input int                Signal_RVI_PeriodRVI         =10;          // Relative Vigor Index(10) Period of calculation
input double             Signal_RVI_Weight            =1.0;         // Relative Vigor Index(10) Weight [0...1.0]

input int                Signal_Stoch_PeriodK         =8;           // Stochastic(8,3,3,...) K-period
input int                Signal_Stoch_PeriodD         =3;           // Stochastic(8,3,3,...) D-period
input int                Signal_Stoch_PeriodSlow      =3;           // Stochastic(8,3,3,...) Period of slowing
 ENUM_STO_PRICE     Signal_Stoch_Applied         =STO_LOWHIGH; // Stochastic(8,3,3,...) Prices to apply to
input double             Signal_Stoch_Weight          =1.0;         // Stochastic(8,3,3,...) Weight [0...1.0]

input int                Signal_TriX_PeriodTriX       =14;          // Triple Exponential Average Period of calculation
 ENUM_APPLIED_PRICE Signal_TriX_Applied          =PRICE_CLOSE; // Triple Exponential Average Prices series
input double             Signal_TriX_Weight           =1.0;         // Triple Exponential Average Weight [0...1.0]

input int                Signal_TEMA_PeriodMA         =12;          // Triple Exponential Moving Average Period of averaging
 int                Signal_TEMA_Shift            =0;           // Triple Exponential Moving Average Time shift
 ENUM_APPLIED_PRICE Signal_TEMA_Applied          =PRICE_CLOSE; // Triple Exponential Moving Average Prices series
input double             Signal_TEMA_Weight           =1.0;         // Triple Exponential Moving Average Weight [0...1.0]

input int                Signal_WPR_PeriodWPR         =8;           // Williams Percent Range(8) Period of calculation
input double             Signal_WPR_Weight            =1.0;         // Williams Percent Range(8) Weight [0...1.0]
//--- inputs for money
input double             Money_FixLot_Percent         =10.0;        // Percent
input double             Money_FixLot_Lots            =0.1;         // Fixed volume
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
//--- Creating filter CSignalAC
   CSignalAC *filter0=new CSignalAC;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.Weight(Signal_AC_Weight);
//--- Creating filter CSignalAMA
   CSignalAMA *filter1=new CSignalAMA;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.PeriodMA(Signal_AMA_PeriodMA);
   filter1.PeriodFast(Signal_AMA_PeriodFast);
   filter1.PeriodSlow(Signal_AMA_PeriodSlow);
   filter1.Shift(Signal_AMA_Shift);
   filter1.Applied(Signal_AMA_Applied);
   filter1.Weight(Signal_AMA_Weight);
//--- Creating filter CSignalAO
   CSignalAO *filter2=new CSignalAO;
   if(filter2==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter2");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter2);
//--- Set filter parameters
   filter2.Weight(Signal_AO_Weight);
//--- Creating filter CSignalBearsPower
   CSignalBearsPower *filter3=new CSignalBearsPower;
   if(filter3==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter3");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter3);
//--- Set filter parameters
   filter3.PeriodBears(Signal_BearsPower_PeriodBears);
   filter3.Weight(Signal_BearsPower_Weight);
//--- Creating filter CSignalBullsPower
   CSignalBullsPower *filter4=new CSignalBullsPower;
   if(filter4==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter4");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter4);
//--- Set filter parameters
   filter4.PeriodBulls(Signal_BullsPower_PeriodBulls);
   filter4.Weight(Signal_BullsPower_Weight);
//--- Creating filter CSignalCCI
   CSignalCCI *filter5=new CSignalCCI;
   if(filter5==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter5");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter5);
//--- Set filter parameters
   filter5.PeriodCCI(Signal_CCI_PeriodCCI);
   filter5.Applied(Signal_CCI_Applied);
   filter5.Weight(Signal_CCI_Weight);
//--- Creating filter CSignalDeM
   CSignalDeM *filter6=new CSignalDeM;
   if(filter6==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter6");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter6);
//--- Set filter parameters
   filter6.PeriodDeM(Signal_DeM_PeriodDeM);
   filter6.Weight(Signal_DeM_Weight);
//--- Creating filter CSignalDEMA
   CSignalDEMA *filter7=new CSignalDEMA;
   if(filter7==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter7");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter7);
//--- Set filter parameters
   filter7.PeriodMA(Signal_DEMA_PeriodMA);
   filter7.Shift(Signal_DEMA_Shift);
   filter7.Applied(Signal_DEMA_Applied);
   filter7.Weight(Signal_DEMA_Weight);
//--- Creating filter CSignalEnvelopes
   CSignalEnvelopes *filter8=new CSignalEnvelopes;
   if(filter8==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter8");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter8);
//--- Set filter parameters
   filter8.PeriodMA(Signal_Envelopes_PeriodMA);
   filter8.Shift(Signal_Envelopes_Shift);
   filter8.Method(Signal_Envelopes_Method);
   filter8.Applied(Signal_Envelopes_Applied);
   filter8.Deviation(Signal_Envelopes_Deviation);
   filter8.Weight(Signal_Envelopes_Weight);
//--- Creating filter CSignalFrAMA
   CSignalFrAMA *filter9=new CSignalFrAMA;
   if(filter9==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter9");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter9);
//--- Set filter parameters
   filter9.PeriodMA(Signal_FraMA_PeriodMA);
   filter9.Shift(Signal_FraMA_Shift);
   filter9.Applied(Signal_FraMA_Applied);
   filter9.Weight(Signal_FraMA_Weight);
//--- Creating filter CSignalMACD
   CSignalMACD *filter10=new CSignalMACD;
   if(filter10==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter10");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter10);
//--- Set filter parameters
   filter10.PeriodFast(Signal_MACD_PeriodFast);
   filter10.PeriodSlow(Signal_MACD_PeriodSlow);
   filter10.PeriodSignal(Signal_MACD_PeriodSignal);
   filter10.Applied(Signal_MACD_Applied);
   filter10.Weight(Signal_MACD_Weight);
//--- Creating filter CSignalMA
   CSignalMA *filter11=new CSignalMA;
   if(filter11==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter11");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter11);
//--- Set filter parameters
   filter11.PeriodMA(Signal_MA_PeriodMA);
   filter11.Shift(Signal_MA_Shift);
   filter11.Method(Signal_MA_Method);
   filter11.Applied(Signal_MA_Applied);
   filter11.Weight(Signal_MA_Weight);
//--- Creating filter CSignalSAR
   CSignalSAR *filter12=new CSignalSAR;
   if(filter12==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter12");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter12);
//--- Set filter parameters
   filter12.Step(Signal_SAR_Step);
   filter12.Maximum(Signal_SAR_Maximum);
   filter12.Weight(Signal_SAR_Weight);
//--- Creating filter CSignalRSI
   CSignalRSI *filter13=new CSignalRSI;
   if(filter13==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter13");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter13);
//--- Set filter parameters
   filter13.PeriodRSI(Signal_RSI_PeriodRSI);
   filter13.Applied(Signal_RSI_Applied);
   filter13.Weight(Signal_RSI_Weight);
//--- Creating filter CSignalRVI
   CSignalRVI *filter14=new CSignalRVI;
   if(filter14==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter14");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter14);
//--- Set filter parameters
   filter14.PeriodRVI(Signal_RVI_PeriodRVI);
   filter14.Weight(Signal_RVI_Weight);
//--- Creating filter CSignalStoch
   CSignalStoch *filter15=new CSignalStoch;
   if(filter15==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter15");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter15);
//--- Set filter parameters
   filter15.PeriodK(Signal_Stoch_PeriodK);
   filter15.PeriodD(Signal_Stoch_PeriodD);
   filter15.PeriodSlow(Signal_Stoch_PeriodSlow);
   filter15.Applied(Signal_Stoch_Applied);
   filter15.Weight(Signal_Stoch_Weight);
//--- Creating filter CSignalTriX
   CSignalTriX *filter16=new CSignalTriX;
   if(filter16==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter16");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter16);
//--- Set filter parameters
   filter16.PeriodTriX(Signal_TriX_PeriodTriX);
   filter16.Applied(Signal_TriX_Applied);
   filter16.Weight(Signal_TriX_Weight);
//--- Creating filter CSignalTEMA
   CSignalTEMA *filter17=new CSignalTEMA;
   if(filter17==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter17");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter17);
//--- Set filter parameters
   filter17.PeriodMA(Signal_TEMA_PeriodMA);
   filter17.Shift(Signal_TEMA_Shift);
   filter17.Applied(Signal_TEMA_Applied);
   filter17.Weight(Signal_TEMA_Weight);
//--- Creating filter CSignalWPR
   CSignalWPR *filter18=new CSignalWPR;
   if(filter18==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter18");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter18);
//--- Set filter parameters
   filter18.PeriodWPR(Signal_WPR_PeriodWPR);
   filter18.Weight(Signal_WPR_Weight);
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
