//+------------------------------------------------------------------+
//|                                                    SARSTORSI.mq5 |
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
#include <Expert\Signal\SignalSAR.mqh>
#include <Expert\Signal\SignalStoch.mqh>
#include <Expert\Signal\SignalRSI.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingFixedPips.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title                  ="SARSTORSI"; // Document name
ulong                    Expert_MagicNumber            =193;         //
bool                     Expert_EveryTick              =false;       //
//--- inputs for main signal
input int                Signal_ThresholdOpen          =10;          // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose         =10;          // Signal threshold value to close [0...100]
input double             Signal_PriceLevel             =0.0;         // Price level to execute a deal
input double             Signal_StopLevel              =50.0;        // Stop Loss level (in points)
input double             Signal_TakeLevel              =50.0;        // Take Profit level (in points)
input int                Signal_Expiration             =4;           // Expiration of pending orders (in bars)
input double             Signal_SAR_Step               =0.02;        // Parabolic SAR(0.02,0.2) Speed increment
input double             Signal_SAR_Maximum            =0.2;         // Parabolic SAR(0.02,0.2) Maximum rate
input double             Signal_SAR_Weight             =1.0;         // Parabolic SAR(0.02,0.2) Weight [0...1.0]
input int                Signal_Stoch_PeriodK          =8;           // Stochastic(8,3,3,...) K-period
input int                Signal_Stoch_PeriodD          =3;           // Stochastic(8,3,3,...) D-period
input int                Signal_Stoch_PeriodSlow       =3;           // Stochastic(8,3,3,...) Period of slowing
input ENUM_STO_PRICE     Signal_Stoch_Applied          =STO_LOWHIGH; // Stochastic(8,3,3,...) Prices to apply to
input double             Signal_Stoch_Weight           =1.0;         // Stochastic(8,3,3,...) Weight [0...1.0]
input int                Signal_RSI_PeriodRSI          =8;           // Relative Strength Index(8,...) Period of calculation
input ENUM_APPLIED_PRICE Signal_RSI_Applied            =PRICE_CLOSE; // Relative Strength Index(8,...) Prices series
input double             Signal_RSI_Weight             =1.0;         // Relative Strength Index(8,...) Weight [0...1.0]
//--- inputs for trailing
input int                Trailing_FixedPips_StopLevel  =30;          // Stop Loss trailing level (in points)
input int                Trailing_FixedPips_ProfitLevel=50;          // Take Profit trailing level (in points)
//--- inputs for money
input double             Money_FixLot_Percent          =10.0;        // Percent
input double             Money_FixLot_Lots             =0.1;         // Fixed volume
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
//--- Creating filter CSignalSAR
   CSignalSAR *filter0=new CSignalSAR;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.Step(Signal_SAR_Step);
   filter0.Maximum(Signal_SAR_Maximum);
   filter0.Weight(Signal_SAR_Weight);
//--- Creating filter CSignalStoch
   CSignalStoch *filter1=new CSignalStoch;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.PeriodK(Signal_Stoch_PeriodK);
   filter1.PeriodD(Signal_Stoch_PeriodD);
   filter1.PeriodSlow(Signal_Stoch_PeriodSlow);
   filter1.Applied(Signal_Stoch_Applied);
   filter1.Weight(Signal_Stoch_Weight);
//--- Creating filter CSignalRSI
   CSignalRSI *filter2=new CSignalRSI;
   if(filter2==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter2");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter2);
//--- Set filter parameters
   filter2.PeriodRSI(Signal_RSI_PeriodRSI);
   filter2.Applied(Signal_RSI_Applied);
   filter2.Weight(Signal_RSI_Weight);
//--- Creation of trailing object
   CTrailingFixedPips *trailing=new CTrailingFixedPips;
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
   trailing.StopLevel(Trailing_FixedPips_StopLevel);
   trailing.ProfitLevel(Trailing_FixedPips_ProfitLevel);
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
