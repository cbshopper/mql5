//+------------------------------------------------------------------+
#define EXPERT
//input int MagicNumber = 20032201;

//#include "SymbolSettings.mqh"

#define BARCOUNT 10
#include <cb/CB_ArrayExt.mqh>
//#include "CB_CloseSignals.mqh"
#include "EABody.mqh"
//*===========================================================================================
// global vars for Expert
//*===========================================================================================
double IndBuffer0[];
double IndBuffer1[];
double IndBuffer2[];
double IndBuffer3[];
double IndBuffer4[];
double IndBuffer5[];
double Help0[];
double Help1[];


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitArrays(int initlen)
  {
   ResizeArrays(initlen);

   ArrayFill(IndBuffer0,0,initlen,0);
   ArrayFill(IndBuffer1,0,initlen,0);
   ArrayFill(IndBuffer2,0,initlen,0);
   ArrayFill(IndBuffer3,0,initlen,0);
   ArrayFill(IndBuffer4,0,initlen,0);
   ArrayFill(IndBuffer5,0,initlen,0);
   ArrayFill(Help0,0,initlen,0);
   ArrayFill(Help1,0,initlen,0);

   bool asSeries = false;
   ArraySetAsSeries(IndBuffer0,asSeries);
   ArraySetAsSeries(IndBuffer1,asSeries);
   ArraySetAsSeries(IndBuffer2,asSeries);
   ArraySetAsSeries(IndBuffer3,asSeries);
   ArraySetAsSeries(IndBuffer4,asSeries);
   ArraySetAsSeries(IndBuffer5,asSeries);
   ArraySetAsSeries(Help0,asSeries);
   ArraySetAsSeries(Help1,asSeries);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ResizeArrays(int len)
  {
   ArrayResize(IndBuffer0,len);
   ArrayResize(IndBuffer1,len);
   ArrayResize(IndBuffer2,len);
   ArrayResize(IndBuffer3,len);
   ArrayResize(IndBuffer4,len);
   ArrayResize(IndBuffer5,len);
   ArrayResize(Help0,len);
   ArrayResize(Help1,len);


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ShiftArrays()
  {
   ArrayShiftDbl(IndBuffer0);
   ArrayShiftDbl(IndBuffer1);
   ArrayShiftDbl(IndBuffer2);
   ArrayShiftDbl(IndBuffer3);
   ArrayShiftDbl(IndBuffer4);
   ArrayShiftDbl(IndBuffer5);
   ArrayShiftDbl(Help0);
   ArrayShiftDbl(Help1);
  }
//*===========================================================================================
void DrawValue(double &IndBuffer[],string name, int style,int col, int shift)
  {
   if(!IsNull(IndBuffer[shift]) && !IsNull(IndBuffer[shift+1]))
      if(style == DRAW_LINE)
         DrawLine(name, shift, IndBuffer[shift],IndBuffer[shift+1], col);
      else
         DrawDot(name, shift, IndBuffer[shift], col);


  }
//*===========================================================================================
void DrawValue(double &IndBuffer[], int id, int shift)
  {
   if(!IsNull(IndBuffer[shift]) && !IsNull(IndBuffer[shift+1]))
      if(IndStyles[id] == DRAW_LINE)
         DrawLine(IndNames[id], shift, IndBuffer[shift],IndBuffer[shift+1], IndColors[id]);
      else
         DrawDot(IndNames[id], shift, IndBuffer[shift], IndColors[id]);


  }
//+------------------------------------------------------------------+
void ClearDrawings()
  {
   ObjectsDeleteAll(0, "open");
   for(int i = 0; i < 6; i++)
     {
      ObjectsDeleteAll(0, (string)IndNames[i]);
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetOpenSignal(int shift)
  {

   double sigpos=0;

   int   signal = 0;
   SignalInfo="";
// InitArrays();
   ShiftArrays();

// GetIndicatorValues(shift,IndBuffer0,IndBuffer1,IndBuffer2, IndBuffer3,IndBuffer4,IndBuffer5,Help0,Help1);

   signal = GetSignalAndValues(shift,IndBuffer0,IndBuffer1,IndBuffer2, IndBuffer3,IndBuffer4,IndBuffer5,Help0,Help1);

// id DrawValue(double &IndBuffer[],string name, int style,int col, int shift)
   //DrawValue(IndBuffer0,0,shift);
   //DrawValue(IndBuffer1,1,shift);
   //DrawValue(IndBuffer2,2,shift);
   //DrawValue(IndBuffer3,3,shift);
   //DrawValue(IndBuffer4,4,shift);
   //DrawValue(IndBuffer5,5,shift);



   if(signal > 0)
     {
      sigpos = iLow(NULL,0,shift+1);  //ma0;
      Print(__FUNCTION__, ": ++ Open BUY ", TimeToString(iTime(NULL,0,shift)));
      DrawDot("OpenBuy", shift, sigpos, clrBlue, 233);
     }

   if(signal < 0)
     {
      sigpos = iHigh(NULL,0,shift+1);  //ma0;
      Print(__FUNCTION__, ": ++ Open SELL ", TimeToString(iTime(NULL,0,shift)));
      DrawDot("OpenSell", shift, sigpos, clrRed, 234);
     }
   return signal;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Expert_OnInit(int barcount=10)
  {
   int ret = INIT_SUCCEEDED;
   START_SHIFT = 0;

   InitArrays(barcount*2+1);
   InitSignals();
   InitSLTPCalculator();
   InitStopSignals();
   TesterHideIndicators(false);


   return ret;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Expert_OnDeInit()
  {
   DeInitSignals();
   DeInitSLTPCalculator();
   DeInitStopSignals();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetCloseSignal(int shift, int mode, int ticket)
  {
   int ret = 0;
 //  if(OrderSelect(ticket))
   if (PositionSelectByTicket(ticket))
     {
      datetime opentime = PositionGetInteger(POSITION_TIME);
      int orderbar = iBarShift(NULL,0,opentime,false);
      if(orderbar > shift+1)
        {
         ret = GetEACloseSignal(shift, mode,ticket);
         if(ret > 0)
           {
            DrawArrowXL("Close", shift, iOpen(NULL,0,shift),40,5,clrRed);
           }
        }
     }
   return ret;
  }



//+------------------------------------------------------------------+
