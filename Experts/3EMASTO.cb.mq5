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
#include <Expert\CB\ExpertCB.mqh>
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\Signal3MASTO.mqh>
#include <Expert\Signal\SignalMACross.mqh>
#include <Expert\Signal\SignalBBFilter.mqh>
#include <Expert\Signal\SignalStoch.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingMA.mqh>
#include <Expert\Trailing\TrailingNone.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title         ="3EMA";      // Document name
ulong                    Expert_MagicNumber   =17535;       //
bool                     Expert_EveryTick     =false;       //
input int            Expert_MaxPositions           = 10;        // max. open Positions
input bool           Expert_AllowMultiOrders    = true;      // allow multiple open Positions
input int            Expert_MinBarDiff          = 2;        // min Bar diff between Positions
input int            Expert_VDelayMinutes   =60;          // delay of virtual stops
input bool           Expert_VUse            = true;      // use VTAKE/VSTOP instead fo Take/Stop
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
 int                Signal_3EMA_Offset   = 3;          // 3MA Shift Offset of previous MA
input int                Signal_3EMA_MinDiff = 1;           // min. Diff of MA2
input int                Signal_3EMA_StoK = 5;           // Sto K-Period
input int                Signal_3EMA_StoD = 3;           // Sto D-Period
input int                Signal_3EMA_StoSlowing = 4;           // Sto Slowing
input int                Signal_3EMA_StoLevel = 20;           // Sto Level
input bool               Signal_3EMA_UseMACross = false;    // Use Cross of MA2 as Signal
input bool               Signal_3EMA_UseStoSignal = false;    // Use Stochastic as Signal
input double             Signal_3EMA_Weight   =1.0;         // 3MA(21,34,50,MODE_SMA,...) Weight [0...1.0]

input int                Signal_BBF_BBPeriod   =14;           // SignalBollingerFilter(14,...) BB Period
input ENUM_APPLIED_PRICE Signal_BBF_BBPrice    =PRICE_MEDIAN; // SignalBollingerFilter(14,...)
input double             Signal_BBF_BBDeviation=1.5;          // SignalBollingerFilter(14,...) BB Deviation
input double             Signal_BBF_Weight     =1.0;          // SignalBollingerFilter(14,...) Weight [0...1.0]
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input int                Signal_EXIT_MA_PeriodMA    =12;          // EXIT Moving Average(12,0,...) Period of averaging
 int                Signal_EXIT_MA_Shift       =0;           // EXIT Moving Average(12,0,...) Time shift
input int                Signal_EXIT_MA_MinHigh       =0;           // EXIT Moving Average(12,0,...) Min High
input ENUM_MA_METHOD     Signal_EXIT_MA_Method      =MODE_SMA;    // EXIT Moving Average(12,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_EXIT_MA_Applied     =PRICE_CLOSE; // EXIT Moving Average(12,0,...) Prices series
input double             Signal_EXIT_MA_Weight      =1.0;         // EXIT Moving Average(12,0,...) Weight [0...1.0]

input int            Signal_EXIT_Stoch_PeriodK   =8;           // Stochastic(8,3,3,...) K-period
input int            Signal_EXIT_Stoch_PeriodD   =3;           // Stochastic(8,3,3,...) D-period
input int            Signal_EXIT_Stoch_PeriodSlow=3;           // Stochastic(8,3,3,...) Period of slowing
input ENUM_STO_PRICE Signal_EXIT_Stoch_Applied   =STO_LOWHIGH; // Stochastic(8,3,3,...) Prices to apply to
input double         Signal_EXIT_Stoch_Weight    =1.0;         // Stochastic(8,3,3,...) Weight [0...1.0]


//--- inputs for trailing
//input int                Trailing_MA_Period  =34;          // Period of MA
//input int                Trailing_MA_Shift   =0;           // Shift of MA
//input ENUM_MA_METHOD     Trailing_MA_Method  =MODE_EMA;    // Method of averaging
//input ENUM_APPLIED_PRICE Trailing_MA_Applied =PRICE_CLOSE; // Prices series


//--- inputs for money
input double             Money_FixLot_Percent =10.0;        // Percent
input double             Money_FixLot_Lots    =0.1;         // Fixed volume
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
#ifdef CEXPERT_CB
CExpertCB ExtExpert;
#else 
CExpert ExtExpert;
#endif

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
#ifdef CEXPERT_CB  
   ExtExpert.MultiOrderMode(Expert_AllowMultiOrders);
   ExtExpert.MaxPositions(Expert_MaxPositions);
   ExtExpert.MinBarDiff(Expert_MinBarDiff);
   ExtExpert.StopLevel(Signal_StopLevel);
   ExtExpert.TakeLevel(Signal_TakeLevel);
   ExtExpert.VDelay(Expert_VDelayMinutes);
   ExtExpert.VUse(Expert_VUse);
#endif   

//--- Creating signal
#ifdef CEXPERT_CB
CExpertSignalCB *signal=new CExpertSignalCB;
#else 
CExpertSignal *signal=new CExpertSignal;
#endif
   
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
   CSignal3MASTO *filter0=new CSignal3MASTO;
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
   filter0.Offset(Signal_3EMA_Offset);
   filter0.UseMACross(Signal_3EMA_UseMACross);
   filter0.UseStoSignal(Signal_3EMA_UseStoSignal);
   filter0.StoK(Signal_3EMA_StoK);
   filter0.StoD(Signal_3EMA_StoD);
   filter0.StoSlowing(Signal_3EMA_StoSlowing);
   filter0.StoLevel(Signal_3EMA_StoLevel);
   filter0.MinDiff(Signal_3EMA_MinDiff);
   
   filter0.Weight(Signal_3EMA_Weight);

//================================== FILTER SIGNAL ============================================
//--- Creating filter CSignalBBFilter
   CSignalBBFilter *filter1=new CSignalBBFilter;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);

//--- Set filter parameters
   filter1.BBFPeriod(Signal_BBF_BBPeriod);
   filter1.BBFPrice(Signal_BBF_BBPrice);
   filter1.BBFDeviation(Signal_BBF_BBDeviation);
   filter1.Weight(Signal_BBF_Weight);


//================================== EXIT SIGNAL ============================================
//--- Creating exit_signal
   CExpertSignalCB *exit_signal=new CExpertSignalCB;
   if(exit_signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating exit_signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ExtExpert.InitExitSignal(exit_signal);
   exit_signal.ThresholdOpen(200);
   exit_signal.ThresholdClose(10);
   exit_signal.PriceLevel(0);
   exit_signal.StopLevel(0);
   exit_signal.TakeLevel(0);
   exit_signal.Expiration(0);

   CSignalMACross *filter_exit=new CSignalMACross;
   if(filter_exit==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter_exit");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }

   exit_signal.AddFilter(filter_exit);
//--- Set filter parameters
   filter_exit.PeriodMA(Signal_EXIT_MA_PeriodMA);
   //filter_exit.Shift(Signal_EXIT_MA_Shift);
   filter_exit.MinHigh(Signal_EXIT_MA_MinHigh);
   filter_exit.Method(Signal_EXIT_MA_Method);
   filter_exit.Applied(Signal_EXIT_MA_Applied);
   filter_exit.Weight(Signal_EXIT_MA_Weight);
   
//--- Creating filter CSignalStoch
   CSignalStoch *filterSto=new CSignalStoch;
   if(filterSto==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filterSto");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   exit_signal.AddFilter(filterSto);
//--- Set filter parameters
   filterSto.PeriodK(Signal_EXIT_Stoch_PeriodK);
   filterSto.PeriodD(Signal_EXIT_Stoch_PeriodD);
   filterSto.PeriodSlow(Signal_EXIT_Stoch_PeriodSlow);
   filterSto.Applied(Signal_EXIT_Stoch_Applied);
   filterSto.Weight(Signal_EXIT_Stoch_Weight);
   filterSto.PatternsUsage(0); 
//==========================================================================================

  //--- Creation of trailing object
  // CTrailingMA *trailing=new CTrailingMA;
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
 //  trailing.Period(Trailing_MA_Period);
 //  trailing.Shift(Trailing_MA_Shift);
  // trailing.Method(Trailing_MA_Method);
 //  trailing.Applied(Trailing_MA_Applied);
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
ExtExpert.Processing();
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


uint SendTestOrder(long const magic_number) 
  { 
   MqlTradeRequest request={0};
   MqlTradeResult  result={0};
//--- parameters of request
   request.action   =TRADE_ACTION_DEAL;                     // type of trade operation
   request.symbol   =Symbol();                              // symbol
   request.volume   =0.1;                                   // volume of 0.1 lot
   request.type     =ORDER_TYPE_BUY;                        // order type
   request.price    =SymbolInfoDouble(Symbol(),SYMBOL_ASK); // price for opening
   request.deviation=5;                                     // allowed deviation from the price
   request.magic    =magic_number;                          // MagicNumber of the order
   request.type_filling   = ORDER_FILLING_IOC;                         // Order execution type 
//--- send the request
   if(!OrderSend(request,result))
      PrintFormat("OrderSend error %d",GetLastError());     // if unable to send the request, output the error code
//--- information about the operation
   PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
   return result.retcode; 
  } 