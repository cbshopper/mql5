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

input  int Signal1MATurn=1;
input  int SignalSAR=1;
input  int Signal2MACross=0;
input  int Signal3MACross=0;
input  int SignalMACD=0;
input  int SignalSTO=0;
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
input int CloseByMaCross = 0;
input int CloseBySAR=1;
input int CloseByOpositeSignal=0;
input int CloseByTimeSignal=0;



// #define TESTING
//#include "common\CB_Commons.mqh"
#include "signals\CB_uniSignal.mqh"
#include "signals\CB_uniSignalLib.mqh"
#include "common\CB_uniFilter1.mqh"

#include "common\CB_CloseSignals.mqh"
#include "common\CB_uniEA.mqh"

