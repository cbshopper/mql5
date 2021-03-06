//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#property version   "0.90"
//#include <cb\gSpeak6.mqh>
#include <cb\CB_Draw.mqh>
#include "CB_SignalChecker.mqh"

double IndBuffer0[];
double IndBuffer1[];
double IndBuffer2[];
double IndBuffer3[];
double IndBuffer4[];
double IndBuffer5[];
double Help0[];
double Help1[];

double SigBuyBuffer[];
double SigSellBuffer[];


int IndPtr0=0;
int IndPtr1=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {

   ArraySetAsSeries(SigBuyBuffer,true);
   ArraySetAsSeries(SigSellBuffer,true);

   IndicatorSetInteger(INDICATOR_DIGITS,Digits() + 1);

//--- indicator lines

   for(int id = 0; id < 6; id++)
     {
      // SetIndexStyle(id, IndType[id], IndStyles[id],IndWidths[id],IndColors[id]);
      PlotIndexSetInteger(id,PLOT_DRAW_TYPE,IndType[id]);
      PlotIndexSetInteger(id,PLOT_LINE_STYLE,IndStyles[id]);
      PlotIndexSetInteger(id,PLOT_LINE_COLOR,IndColors[id]);
      PlotIndexSetInteger(id,PLOT_LINE_WIDTH,IndWidths[id]);
      PlotIndexSetString(id, PLOT_LABEL,IndNames[id]);

     }

   SetIndexBuffer(0, IndBuffer0,INDICATOR_DATA);
   SetIndexBuffer(1, IndBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2, IndBuffer2,INDICATOR_DATA);
   SetIndexBuffer(3, IndBuffer3,INDICATOR_DATA);
   SetIndexBuffer(4, IndBuffer4,INDICATOR_DATA);
   SetIndexBuffer(5, IndBuffer5,INDICATOR_DATA);

   int id=6;
   PlotIndexSetInteger(id,PLOT_DRAW_TYPE,DRAW_ARROW);
   PlotIndexSetInteger(id,PLOT_LINE_STYLE,STYLE_SOLID);
   PlotIndexSetInteger(id,PLOT_LINE_COLOR,clrBlue);
   PlotIndexSetInteger(id,PLOT_LINE_WIDTH,2);
   PlotIndexSetString(id, PLOT_LABEL,"BUY");
   PlotIndexSetInteger(id, PLOT_ARROW,174);
   SetIndexBuffer(id, SigBuyBuffer,INDICATOR_DATA);
  
   id++;
   PlotIndexSetInteger(id,PLOT_DRAW_TYPE,DRAW_ARROW);
   PlotIndexSetInteger(id,PLOT_LINE_STYLE,STYLE_SOLID);
   PlotIndexSetInteger(id,PLOT_LINE_COLOR,clrRed);
   PlotIndexSetInteger(id,PLOT_LINE_WIDTH,2);
   PlotIndexSetString(id, PLOT_LABEL,"SELL");
   PlotIndexSetInteger(id, PLOT_ARROW,174);
   SetIndexBuffer(id, SigSellBuffer,INDICATOR_DATA);
 
   id++;
   SetIndexBuffer(id,Help0,INDICATOR_CALCULATIONS);
 
   id++;
   SetIndexBuffer(id,Help1,INDICATOR_CALCULATIONS);

   for(id = 0; id < 8; id++)
     {
      PlotIndexSetDouble(id,PLOT_EMPTY_VALUE,0);
     }


   bool asSeries = true;
   ArraySetAsSeries(IndBuffer0,asSeries);
   ArraySetAsSeries(IndBuffer1,asSeries);
   ArraySetAsSeries(IndBuffer2,asSeries);
   ArraySetAsSeries(IndBuffer3,asSeries);
   ArraySetAsSeries(IndBuffer4,asSeries);
   ArraySetAsSeries(IndBuffer5,asSeries);
   ArraySetAsSeries(Help0,asSeries);
   ArraySetAsSeries(Help1,asSeries);


//--- name for indicator label
   string myname = StringFormat("%s: %s", MQLInfoString(MQL_PROGRAM_NAME), IndicatorInfo());
   IndicatorSetString(INDICATOR_SHORTNAME,myname);

   ClearLines();
   ObjectsDeleteAll(0,MQLInfoString(MQL_PROGRAM_NAME));

   InitSignals();
   InitSLTPCalculator();
   InitStopSignals();

   if(CheckSignals)
     {
      ShowButtons();
     }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   HideButtons();
   ClearLines();
   DeInitSignals();
   DeInitSLTPCalculator();
   DeInitStopSignals();
   ObjectsDeleteAll(0,MQLInfoString(MQL_PROGRAM_NAME),-1,-1);
   Comment("");
  }

//int limit;
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   int cnt = calculate(rates_total, prev_calculated);
   return cnt;
  }
//+------------------------------------------------------------------+
//| Calculate Values and Trade Signal                                |
//+------------------------------------------------------------------+
int calculate(int rates_total,int prev_calculated)
  {

   int limit = MathMin(rates_total - prev_calculated - 1, rates_total -BarRange - 1);

   if(limit > maxbars)
      limit =maxbars;

   for(int shift = limit; shift >= 0; shift--)
     {

      double nulval =0; //EMPTY_VALUE
      SigBuyBuffer[shift] = nulval;
      SigSellBuffer[shift] = nulval;


      int signal=0;

      // GetIndicatorValues(shift,IndBuffer0,IndBuffer1,IndBuffer2, IndBuffer3,IndBuffer4,IndBuffer5,Help0,Help1);

      signal = GetSignalAndValues(shift,IndBuffer0,IndBuffer1,IndBuffer2, IndBuffer3,IndBuffer4,IndBuffer5,Help0,Help1);

      double price = iOpen(NULL,0,shift);
      if(signal > 0)
        {
         SigBuyBuffer[shift] = price; // MABuffer[index];
         DrawInfoText(MQLInfoString(MQL_PROGRAM_NAME)+ " BUY",shift,price,SignalInfo,ANCHOR_LEFT_LOWER, 0,clrBlue);
         if(shift == 1)
            DoAlert("BUY");
        }
      if(signal < 0)
        {
         SigSellBuffer[shift] = price; //MABuffer[index];
         DrawInfoText(MQLInfoString(MQL_PROGRAM_NAME) + " SELL",shift,price,SignalInfo,ANCHOR_LEFT_UPPER,0,clrRed);
         if(shift == 1)
            DoAlert("SELL");
        }
     }
//--- done
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
void CheckSignal(bool doDraw)
  {
//  ParameterInfo();
   calculate(maxbars,0);
   checkSignal(SigBuyBuffer, SigSellBuffer,StopLoss, TakeProfit,Lots,iCRV,doDraw);
   if(doDraw)
     {
      string msg = ResultMsg();
      string info = ParameterInfo();
      string mymsg = StringFormat("%s %s",
                                  msg, info);

      Comment(mymsg);
     }
  }




//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
sinput string ___ALERT_SETTINGS__ = "----------- Alert Settings -------------";
input bool ShowAlerts=false;
input bool PlaySound= false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DoAlert(string info)
  {
   static datetime previousTime;
   string message;
   if(ShowAlerts)
     {
      if(previousTime!=iTime(NULL,0,0))
        {
         previousTime  = iTime(NULL,0,0);
         message= Symbol() + " at " + TimeToString(TimeLocal(),TIME_SECONDS) + " " + info;
         Alert(message);


         if(PlaySound)
           {
            string msg = StringFormat("Neues Signal %s für %s",info, Symbol());
            //   gSpeak(message,1,100);
            PlaySound("alert2.wav");
           }
        }
     }
  }
//+------------------------------------------------------------------+
