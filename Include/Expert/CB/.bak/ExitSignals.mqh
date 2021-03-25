//+------------------------------------------------------------------+
//|                                                  ExitSignals.mqh |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#define EXITSIGNAL_INCLUDED

#include <Expert\CB\ExpertCB.mqh>
#include <Expert\CB\ExpertSignalCB.mqh>
#include <Expert\CB\ExpertExitSignalCB.mqh>
//--- available signals
#include <Expert\Signal\SignalSAR.mqh>
#include <Expert\Signal\SignalMA.mqh>

input int            ExitSignal_Threshold             =10;       // EXIT Signal threshold value to close [0...100]
input double         ExitSignal_SAR_Step              =0.02;     // EXIT Parabolic SAR(0.02,0.2) Speed increment
input double         ExitSignal_SAR_Maximum           =0.2;      // EXIT Parabolic SAR(0.02,0.2) Maximum rate
input double         ExitSignal_SAR_Weight            =1.0;      // EXIT Parabolic SAR(0.02,0.2) Weight [0...1.0]

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input int                ExitSignal_MA_PeriodMA    =12;          // EXIT Moving Average(12,0,...) Period of averaging
input int                ExitSignal_MA_Shift       =0;           // EXIT Moving Average(12,0,...) Time shift
input ENUM_MA_METHOD     ExitSignal_MA_Method      =MODE_SMA;    // EXIT Moving Average(12,0,...) Method of averaging
input ENUM_APPLIED_PRICE ExitSignal_MA_Applied     =PRICE_CLOSE; // EXIT Moving Average(12,0,...) Prices series
input double             ExitSignal_MA_Weight      =1.0;         // EXIT Moving Average(12,0,...) Weight [0...1.0]


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ExitInit(CExpertCB *ThisExpert)
  {
//--- Creating signal
   CExpertExitSignalCB *exitsignal=new CExpertExitSignalCB;
   if(exitsignal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating CExpertExitSignal");
      ThisExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ThisExpert.InitExitSignal(exitsignal);
   ThisExpert.InitSignal(exitsignal);
   exitsignal.ThresholdExit(ExitSignal_Threshold);

//--- Creating filter CSignalSAR
   CSignalSAR *filter0=new CSignalSAR;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ThisExpert.Deinit();
      return(INIT_FAILED);
     }
   exitsignal.AddFilter(filter0);

// -- Creating filter MA-Signal
   CSignalMA *filter1=new CSignalMA;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ThisExpert.Deinit();
      return(INIT_FAILED);
     }
   exitsignal.AddFilter(filter1);
//--- Set filter parameters
   filter1.PeriodMA(ExitSignal_MA_PeriodMA);
   filter1.Shift(ExitSignal_MA_Shift);
   filter1.Method(ExitSignal_MA_Method);
   filter1.Applied(ExitSignal_MA_Applied);
   filter1.Weight(ExitSignal_MA_Weight);

//--- Check all trading objects parameters
   if(!ThisExpert.ValidationExitSettings())
     {
      //--- failed
      ThisExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Tuning of all necessary indicators
   if(!ThisExpert.InitExitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ThisExpert.Deinit();
      return(INIT_FAILED);
     }
   return 0;
  }
//+------------------------------------------------------------------+
