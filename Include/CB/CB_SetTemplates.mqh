//+------------------------------------------------------------------+
//|                                        SetTemplate4AllCharts.mqh |
//|                                                   Christof Blank |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Christof Blank"
#property link      "https://www.mql5.com"
#property strict

#include <cb\CB_Utils.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
#import "user32.dll"
int      PostMessageA(int hWnd,int Msg,int wParam,int lParam);
int      GetParent(int hWnd);
#import
string  TESTER="tester.tpl";
//extern int PeriodInSeconds=5;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  SetZoom(long ID,int Scale)
  {
   bool ok = ChartSetInteger(ID,CHART_SCALE,Scale);

   return(ok);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SetAllZoom(long MyID)
  {
   bool ret=true;
    bool ok=false;
   long  ID=ChartFirst();
   int scale= ChartGetInteger(MyID,CHART_SCALE,0);
   while(ID!=-1)
     {
      if(ID!=MyID || MyID==-1)
        {
          ok=SetZoom(ID,scale);
          if (!ok)
          {
             string msg = "";
             StringConcatenate(msg,"Failed to scale chart error code: ", IntegerToString(GetLastError()));
             Alert(msg);
             ret=false;
             break;
          }
        }
      ID=ChartNext(ID);
     }
     return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  StoreTemplate(string fn)
  {
   bool ok=false;
   long  CID=ChartID();

   ok=ChartSaveTemplate(CID,fn);
   if(!ok)
     {
      string msg ="Failed to store template: \n" + fn   +"\nerror code: " + GetLastError();
      Alert(msg);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  SetTemplates2This()
  {
   bool ok=false;
   long  CID=ChartID();

   long  ID=ChartFirst();
   string fn="_current.tpl";

   ok=ChartSaveTemplate(CID,fn);

   if(ok)
     {
      SetTemplates(fn,CID);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  SetTemplates2Default()
  {
   string fn="";
//   fn=TerminalInfoString(TERMINAL_DATA_PATH)+"\\templates\\default.tpl";
// fn="\\templates\\default.tpl";
   fn="default.tpl";

//  bool ret = FileIsExist(fn) ; //("\\templates\\default.tpl");
   bool ret=true;
   if(ret)
     {

      SetTemplates(fn,-1);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SetTemplates(string fn,long MyID)
  {
   bool ret= true;
   long  ID=ChartFirst();
   while(ID!=-1)
     {
      if(ID!=MyID || MyID==-1)
        {
         bool ok=ChartApplyTemplate(ID,fn);
         if(!ok)
           {
            string chartname = ChartSymbol(ID);
            string tf = TimeFrameToString(ChartPeriod(ID));
            Alert(StringFormat("Failed to apply: %s to Chart %s %s,  error code: %d",fn,chartname,tf,GetLastError()));
          //  ret=false;
          //  break;
           }
        }
      ID=ChartNext(ID);
     }
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  SetTimePeriods()
  {

   long  CID=ChartID();

   ENUM_TIMEFRAMES  TS=ChartPeriod(CID);
   bool ret = SetSymbolPeriods(TS,CID);
   SetAllZoom(CID);
   return ret;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  SetTimePeriods(ENUM_TIMEFRAMES TS)
  {

  long  CID=ChartID();

   bool ret = SetSymbolPeriods(TS,CID);
   //current als last!
 //    string sym=ChartSymbol(CID);
 //  bool ok=ChartSetSymbolPeriod(CID,sym,TS);
 //  SetAllZoom(CID);
   return ret;
  }  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SetSymbolPeriods(ENUM_TIMEFRAMES TS,long MyID)
  {
   bool ok=false;
   bool ret =true;
   long  ID=ChartFirst();
   while(ID!=-1)
     {
      if(ID!=MyID || MyID==-1)
        {
         string sym=ChartSymbol(ID);
         ok=ChartSetSymbolPeriod(ID,sym,TS);
         if(!ok)
           {
            int error = GetLastError();
    //       if (error != 4024)
            {
            Alert("Failed to apply Timeframe " + TS + "\n error code: ",error);
            }
            ret=false;
//            break;
           }
        }
      ID=ChartNext(ID);
     }
     return ret;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
int  BackupTemplate(string tname)
{
  
  long ID = ChartOpen(Symbol(),Period());
  ChartApplyTemplate(ID,tname);
  string timestamp=TimeToString(TimeLocal());
  StringReplace(timestamp,":","");
  int repcnt = StringReplace(tname,".tpl",StringFormat(".%s.tpl",timestamp));
  if (repcnt > 0)
  {
    tname = "tester\\"+tname;
    ChartSaveTemplate(ID,tname);
  }
  ChartClose(ID);
  return ID;
}

bool Copy2Tester(long CID)
{

  BackupTemplate(TESTER);
  ChartNavigate(CID,CHART_CURRENT_POS,0);
  ChartSaveTemplate(CID,TESTER);
  return true;
}
