//+------------------------------------------------------------------+
//|                                                    CB_Notify.mqh |
//|                                                   Copyright 2022 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022 Christof Blank"
#property link      "https://www.???.???"

input bool sendNotifies = true;
//+------------------------------------------------------------------+
datetime lastalert=TimeCurrent();
void DoAlert(int bar, string txt)
{
   if (!sendNotifies) return;
   datetime now = iTime(NULL,0,bar);
   if (now > lastalert)
   {
   
     string msgtxt = txt + ": " + Symbol() + " " + TimeToString(now);
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
  DoAlert(bar,txt);
  DoNotify(bar,txt);
}