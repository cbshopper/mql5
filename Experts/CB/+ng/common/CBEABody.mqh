//+------------------------------------------------------------------+
//|                                               EABody.mqh |
//+------------------------------------------------------------------+




#include "CBcExpert.mqh"


// extern int Expert_OnInit(CcbExpert  *expert);

input  string           COMMONS = "-------- Common EA Settings -------------";
input int         StartShift=1;
input  double     Lots = 0.1;
input double      TotalEquityRisk = 0.0;    //Total Equity Risk
input bool        EtheryTick=false;
input bool        DoNotAutoClose=false;


//CcbExpert MyExpert;
CcbExpert *MyExpert;


// EA BASIC Functions ===============================================+
//+------------------------------------------------------------------+
//| OnTick function                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

   MyExpert.Trade();
//---
  }
//+------------------------------------------------------------------+
int  OnInit()
  {

   MyExpert = new CcbExpert();  
  // CcbExpert * myexpert = GetPointer(MyExpert);
  
    
    int ret = Expert_OnInit(MyExpert);   
   if(ret == INIT_SUCCEEDED)
     {
      Print(__FUNCTION__, ": ", __FILE__, " *****************************************************************************");
     
      MyExpert.SetEtheryTick(EtheryTick);
      MyExpert.SetLots(Lots);
      MyExpert.SetTotalEquityRisk(TotalEquityRisk);
      MyExpert.SetStartShift(StartShift);
      MyExpert.SetAutoCloseOff(DoNotAutoClose);

#ifdef TESTING
      EventSetTimer(2);
#endif
     }

   else
     {

     }
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
   EventKillTimer();
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   OnTick();
  }

