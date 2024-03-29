//+------------------------------------------------------------------+
//|                                                    CB_Notify.mqh |
//|                                                   Copyright 2022 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022 Christof Blank"
#property link      "https://www.???.???"
#include <CB/CB_Utils.mqh>
input bool AlertsOn = false;
input bool sendNotifies = false;

//+------------------------------------------------------------------+
datetime lastalert=TimeCurrent();
void DoAlert(int bar, string txt)
{
   if (!AlertsOn) return;
   datetime now = iTime(NULL,0,bar);
   if (now > lastalert)
   {
     Alert(txt);
     lastalert=now;
   }
}
datetime lastnotification=TimeCurrent();
void DoNotify(int bar, string txt)
{
   if (!sendNotifies) return;
   datetime now = iTime(NULL,0,bar);
   if (now > lastnotification)
   {
     
     SendNotification(txt);
     lastnotification=now;
     
   }
}


void DoAlertX(int bar, string txt)
{
  datetime now = iTime(NULL,0,bar);
  string msgtxt = txt + ": " + Symbol() + " " + timeFrameToString(Period()) + " " + TimeToString(now);
  DoAlert(bar,msgtxt);
  DoNotify(bar,msgtxt);
}