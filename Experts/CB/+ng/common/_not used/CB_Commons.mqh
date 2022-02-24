//+------------------------------------------------------------------+
//|                                                   CB_Commons.mqh |
//|                                                   Christof blank |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Christof Blank"
#property strict

#ifndef SIGNAL_SETTINGS
input string SIGNLAL_Settings = "--------  SIGNAL Settings -------------";
input int BarRange=1;
input int MinSignalScore=1;
#endif
extern string SignalInfo;

int lastSignal=0;
datetime lastSignalTime=0;
//+------------------------------------------------------------------+
int GetSignal(int shift,int barRange,int minSignals)
  {
   int ret=0;
   if(barRange<=0)
      barRange=1;
   int cnt=0;
   int lastSigalBar=0;
   int zero_shift=shift;
   int check_shift=shift;
     SignalInfo="";


   if(lastSignalTime>0)
     {
      lastSigalBar=iBarShift(NULL,0,lastSignalTime,true);
      if(lastSigalBar<0)
         lastSigalBar=0;
     }
   if(shift+barRange<lastSigalBar)
     {
      lastSignal=0;
     }
   if(lastSignal==0 && MinSignalScore>0)
     {
    
      for(int i=shift; i<shift+barRange; i++)
        {
         int sig=GetSignal(i);
         cnt+=sig;
         if(MathAbs(cnt)>=MinSignalScore)
            break;
        }
      //  Print(__FUNCTION__,": cnt=",cnt);
      if(cnt>=MinSignalScore)   // && lastSignal<=0)
        {
         ret=1;
        }
      if(cnt<=-MinSignalScore) // && lastSignal>=0)
        {
         ret=-1;
        }
   
      if (ret !=0)
      {
        lastSignalTime = iTime(NULL,0,shift);
        lastSignal= ret;
      }
      
     }
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetSignalAndValues(int shift, double &IndBuffer0[],double &IndBuffer1[],double &IndBuffer2[],
                       double &IndBuffer3[],double &IndBuffer4[],double &IndBuffer5[],
                       double &Help0[],double &Help1[])
  {
       double nulval =0; //EMPTY_VALUE
      IndBuffer0[shift] = nulval;
      IndBuffer1[shift] = nulval;
      IndBuffer2[shift] = nulval;
      IndBuffer3[shift] = nulval;
      IndBuffer4[shift] = nulval;
      IndBuffer5[shift] = nulval;
      
    //  if (BarRange==0) BarRange=1;
      
      GetValues(shift,IndBuffer0, IndBuffer1,IndBuffer2,IndBuffer3,IndBuffer4,IndBuffer5, Help0,Help1);
      int signal = GetSignal(shift,BarRange,MinSignalScore);
      signal = FilterSignal(signal, shift);
   if (signal !=0)
      {
        lastSignalTime = iTime(NULL,0,shift);
        lastSignal= signal;
      }
   return signal;
  }



  
