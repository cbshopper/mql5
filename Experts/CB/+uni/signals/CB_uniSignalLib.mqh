//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <cb\CB_Commons.mqh>
#include <cb\CB_IMAX.mqh>


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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GETSIGNAL(string signalname,bool enable_buy,bool enable_sell,int shift)
  {
   int ret=0;
   if(enable_buy)
      ret = 1;
   if(enable_sell)
      ret = -1;
   if(ret!=0)
     {
      SetSignalInfo(signalname);
     // Print(signalname,": Time=",TimeToString(iTime(NULL,0,shift))," ret= ",ret);
     }
   return ret;
  }

input string __SIGNAL_SELECTION_ = " ================== SIGNAL PARAMETER SELECTION ==================";

//*===========================================================================================
// Parameter Section
//*===========================================================================================
#ifdef SIGNALS_MA

input string __MA_SETTINGS_ = " ----------------  MA SETTINGS ----------------  ";
input ENUM_MMA_METHOD Ma1Method = MMODE_EMA;
input ENUM_MMA_METHOD Ma2Method=MMODE_HULLMA;
input ENUM_MMA_METHOD Ma3Method=MMODE_HULLMA;

input int Filter=1;
input int Ma1Period=28;
input double Ma2Factor=2.0;
input double Ma3Factor=6.0;

#else

ENUM_MMA_METHOD Ma1Method = MMODE_HULLMA;
ENUM_MMA_METHOD Ma2Method=MMODE_HULLMA;
ENUM_MMA_METHOD Ma3Method=MMODE_HULLMA;

int Filter=1;
int Ma1Period=28;
double Ma2Factor=2.0;
double Ma3Factor=6.0;

#endif

ENUM_APPLIED_PRICE Ma1Price=PRICE_OPEN;
ENUM_APPLIED_PRICE Ma2Price=PRICE_OPEN;
ENUM_APPLIED_PRICE Ma3Price=PRICE_OPEN;

#ifdef SIGNALS_MACD
input string __MACD_SETTINGS_ = " ---------------- MACD SETTINGS -------------------";
input int macd_signal_period=9;
#else
int macd_signal_period=9;
#endif

#ifdef SIGNALS_SAR

input string __SAR_SETTINGS_ = " ---------------- SAR SETTINGS -------------------";
input double open_sar_step = 0.0025;
input double open_sar_max = 0.1;
#else
double open_sar_step = 0.0025;
double open_sar_max = 0.1;

#endif

#ifdef SIGNALS_STO

input string __STO_SETTINGS_ = " ---------------- STO SETTINGS -------------------";
input int sto_KPeriod=14;
input int sto_DPeriod=14;
input int sto_Slowing=9;
input int sto_level=20;
#else
int sto_KPeriod=14;
int sto_DPeriod=14;
int sto_Slowing=9;
int sto_level=20;
#endif

string SignalInfo="";

int STO1Ptr=INVALID_HANDLE;
int MacdPtr=INVALID_HANDLE;
int Sar1Ptr=INVALID_HANDLE;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitSignals()
  {
   if(STO1Ptr==INVALID_HANDLE)
     {
      STO1Ptr =iStochastic(NULL,0,sto_KPeriod,sto_DPeriod,sto_Slowing,MODE_EMA,0);
     }
   if(Sar1Ptr==INVALID_HANDLE)
     {
      Sar1Ptr= iSAR(NULL,0,open_sar_step,open_sar_max);
     }
  
   if(MacdPtr==INVALID_HANDLE)
     {
      if(Ma1Method != MMODE_HULLMA)
        {
         MacdPtr=iMACD(NULL,0,Ma1Period,Ma1Period*Ma2Factor,macd_signal_period,PRICE_CLOSE);

        }
      else
        {
         MacdPtr= iCustom(NULL,0,"cb\\ma\\CB_MACD_hull",Ma1Period,Ma1Period*Ma2Factor,macd_signal_period,2.0,true);
        }
     }
  }
void DeInitSignals()

  {
   if(Sar1Ptr!=INVALID_HANDLE)
     {
      IndicatorRelease(Sar1Ptr);
     }
   if(STO1Ptr!=INVALID_HANDLE)
     {
      IndicatorRelease(STO1Ptr);
     }

   if(MacdPtr!=INVALID_HANDLE)
     {
      IndicatorRelease(MacdPtr);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetSignalInfo(string info)
  {
   if(StringFind(SignalInfo,info) < 0)
     {
      SignalInfo=SignalInfo + "[" + info + "]";
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetSignalSingle(double ma00, double ma01,double ma02, double ma20,double ma21,int shift)
  {
   int ret = 0;
   bool enable_buy =  false;
   bool enable_sell = false;

   enable_buy =  ma02 > ma01 && ma00 > ma01 && iOpen(NULL,0,shift) <  ma20  && ma20 > ma21;
   enable_sell = ma02 < ma01 && ma00 < ma01 && iOpen(NULL,0,shift) >  ma20  && ma20 < ma21;
// GETSIGNAL
   ret = GETSIGNAL("1MATurn",enable_buy,enable_sell,shift);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetSignalCross(double ma00, double ma01,double ma02, double ma10, double ma11, double ma12, int shift)
  {
   int ret = 0;
   if(Ma2Factor < 1)
      return ret;
   bool enable_buy =  false;
   bool enable_sell = false;

   enable_buy =  ma00 > ma10 && ma01 < ma11 && ma02 < ma12 ;
   enable_sell =  ma00 < ma10 && ma01 > ma11 && ma02 > ma12;


// GETSIGNAL
   ret = GETSIGNAL("2MACross",enable_buy,enable_sell,shift);
   return ret;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetSignal3MA(double ma00, double ma01,double ma10, double ma11, double ma20, double ma21,  int shift)
  {
   int ret = 0;
   bool enable_buy =  false;
   bool enable_sell = false;


   bool up_ok = ma00 > ma10 ; //&& ma10 > ma20;
   bool dn_ok = ma00 < ma10 ; //&& ma10 < ma20;

   enable_buy =  ma01 < ma11 && ma00 > ma10 && up_ok;
   enable_sell = ma01 > ma11 && ma00 < ma10 && dn_ok;


// GETSIGNAL
   ret = GETSIGNAL("3MACross",enable_buy,enable_sell,shift);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetSignalMACD(int shift)
  {
   int ret = 0;
   double macd0,macd1,sig0,sig1;


   if(Ma2Factor < 1)
      return ret;


   macd0 = GetIndicatorBufferValue(MacdPtr,shift,0);
   macd1 = GetIndicatorBufferValue(MacdPtr,shift+1,0);
   sig0 = GetIndicatorBufferValue(MacdPtr,shift,1);
   sig1 = GetIndicatorBufferValue(MacdPtr,shift+1,1);


   bool enable_buy =  false;
   bool enable_sell = false;

   enable_buy =  macd1 < sig1 && macd0 > sig0;
   enable_sell = macd1 > sig1 && macd0 < sig0;

// GETSIGNAL
   ret = GETSIGNAL("MACD",enable_buy,enable_sell,shift);
   return ret;
  }

/*
//+------------------------------------------------------------------+
//| Open SIgnal                                                      |
//+------------------------------------------------------------------+
input int SignalChannel=0;

int GetSignalHULLCHANNEL(double ma00, double ma01, double ma10,double hi0, double hi1, double lo0, double lo1,    int shift)
{
 int ret = 0;
 bool enable_buy =  false;
 bool enable_sell = false;

 enable_buy =  ma01 < lo1 && ma00 > lo0 && iOpen(NULL,0,shift) < ma10 ;
 enable_sell = ma01 > hi1 && ma00 < hi0 && iOpen(NULL,0,shift) > ma10 ;

//if (enable_sell) Print(StringFormat("$$$$$$$$$$$$$$$$$$$$check_OverUnderMA: ma2=%f ma0=%f ma1=%f enable_buy=%d enable_sell=%d ",ma2,ma0,ma1,enable_buy,enable_sell));
 GETSIGNAL
 return ret;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input int SignalDirection=0;

int GetSignalDirection(double ma00, double ma01,double ma02, double ma10, double ma11, double ma12,  int shift)
{
 int ret = 0;

 bool enable_buy =  false;
 bool enable_sell = false;

 enable_buy  =  ma00 > ma01 && ma01 > ma02 && ma12 >= ma11 && ma10 > ma11;
 enable_sell =  ma00 < ma01 && ma01 < ma02 && ma12 <= ma11 && ma10 < ma11;

 GETSIGNAL
 return ret;
}
*/

//+------------------------------------------------------------------+
//| Signal SAR                                                                |
//+------------------------------------------------------------------+
int GetSignalSAR(int shift)
  {
   int ret = 0;
   bool enable_buy =  false;
   bool enable_sell = false;
   int offset=0;


   double sar_open0 = GetIndicatorValue(Sar1Ptr,shift);
   double sar_open1 =  GetIndicatorValue(Sar1Ptr,shift+3);

   double CLOSE0 = iClose(NULL,0,shift + offset);
   double CLOSE1 = iClose(NULL,0,shift + offset+2);
   int signal = SarSignal(sar_open0,sar_open1,CLOSE0,CLOSE1);
   enable_buy = signal > 0;
   enable_sell = signal < 0;

// GETSIGNAL
   ret = GETSIGNAL("SAR",enable_buy,enable_sell,shift);

   return ret;
  }






//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getSignalSTO(int shift)
  {
   int ret = 0;
   bool enable_buy=false;
   bool enable_sell=false;

   double sto0 = GetIndicatorBufferValue(STO1Ptr,0,shift);
   double sig0 = GetIndicatorBufferValue(STO1Ptr,1,shift);
   double sto1 = GetIndicatorBufferValue(STO1Ptr,0,shift+1);
   double sig1 = GetIndicatorBufferValue(STO1Ptr,1,shift+1);
   double sto2 = GetIndicatorBufferValue(STO1Ptr,0,shift+2);
// if (sto0 > 100-sto_level || sto0 < sto_level)
     {
      //   enable_buy = sto0>sig0 && sto1 < sig1  && sto0 < sto_level;
      //   enable_sell= sto0<sig0 && sto1 > sig1  && sto0 > 100-sto_level;

      enable_buy = enable_buy || (sto0>sto_level && sto1 < sto_level); // && sto2 < sto_level;
      enable_sell= enable_sell || (sto0<100-sto_level && sto1 > 100-sto_level); // && sto2 > 100-  sto_level;

     }
// GETSIGNAL
   ret = GETSIGNAL("STO",enable_buy,enable_sell,shift);
   return ret;
  }


//+------------------------------------------------------------------+



