#define EXPERT
input  string SPEZIFIC = "--------  EA Settings -------------";
input int MagicNumber = 20032201;

#define TESTINGxxxx

#define SIGNALS_MA
#define SIGNALS_SAR
#define SIGNALS_MACD
#define SIGNALS_STO


#define SIGNAL_SETTINGS
input  string SIGNAL_Settings = "--------  SIGNAL Settings -------------";
input  int BarRange=1;
input  int MinSignalScore=1;
input  string SIGSEL_Settings = "--------  SIGNAL Selection -------------";

  int Signal1MATurn=0;
  int SignalSAR=0;
  int Signal2MACross=0;
  int Signal3MACross=0;
  int SignalMACD=0;
  int SignalSTO=1;
//input  int SignalRSISTO=0;
//input  int SignalMASTO=0;

#define CLOSE_SETTINGS
#define EXITSLTP
#define EXITRISC
#define EXITATR
#define EXITHILO

sinput string _CLOSE_SETTINGS2_ = " ================  CLOSE SIGNALS ================= ";
input int CloseByFixSL=0;
input int ClosebyFixTP=0;
input int ClosebyHILOSL=0;
input int ClosebyHILOTP=0;
input int CloseByATRSL=0;
input int CloseByATRTP=0;
input int CloseByRiskSL=0;
input int CloseByRiskTP=0;
input int CloseByStopMa = 0;
 int CloseByMaCross = 0;
input int CloseBySAR=1;
input int CloseByOpositeSignal=0;
 int CloseByTimeSignal=0;



// #define TESTING
//#include "common\CB_Commons.mqh"
#include "signals\CB_uniSignal.mqh"
#include "signals\CB_uniSignalLib.mqh"
#include "common\CB_uniFilter1.mqh"

#include "common\CB_CloseSignals.mqh"
#include "common\CB_uniEA.mqh"

