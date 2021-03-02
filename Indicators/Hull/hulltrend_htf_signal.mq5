//+------------------------------------------------------------------+ 
//|                                         HullTrend_HTF_Signal.mq5 | 
//|                               Copyright � 2015, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright � 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//--- ����� ������ ����������
#property version   "1.60"
//+------------------------------------------------+ 
//| ��������� ��������� ����������                 |
//+------------------------------------------------+ 
//--- ��������� ���������� � ������� ����
#property indicator_chart_window 
#property indicator_buffers 1
#property indicator_plots   1
//+------------------------------------------------+ 
//| ���������� ��������                            |
//+------------------------------------------------+
#define INDICATOR_NAME      "HullTrend"         // ��� ����������
#define RESET               0                   // ��������� ��� �������� ��������� ������� �� �������� ����������
#define NAMES_SYMBOLS_FONT  "Georgia"           // ����� ��� �������� ����������
#define SIGNAL_SYMBOLS_FONT "Wingdings 3"       // ����� ��� ������� ����� � �������
#define TREND_SYMBOLS_FONT  "Wingdings 3"       // ����� ��� ������� ������
#define UP_SIGNAL_SYMBOL    "�"                 // ������ ��� ���������� long
#define DN_SIGNAL_SYMBOL    "�"                 // ������ ��� ���������� short
#define UP_TREND_SYMBOL     "�"                 // ������ ��� ��������� ������
#define DN_TREND_SYMBOL     "�"                 // ������ ��� ��������� ������
#define BUY_SOUND           "alert.wav"         // �������� ���� ��� ����� � long
#define SELL_SOUND          "alert.wav"         // �������� ���� ��� ����� � short
#define BUY_ALERT_TEXT      "Buy signal"        // ����� ������ ��� ����� � long
#define SELL_ALERT_TEXT     "Sell signal"       // ����� ������ ��� ����� � short
//+------------------------------------------------+ 
//| ������������ ��� ��������� ������������ ������ |
//+------------------------------------------------+ 
enum ENUM_ALERT_MODE // ��� ���������
  {
   OnlySound,   // ������ ����
   OnlyAlert    // ������ �����
  };
//+------------------------------------------------+ 
//| �������� ������ CXMA                           |
//+------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------+ 
//| ���������� ������������                        |
//+------------------------------------------------+ 
/*enum Smooth_Method - ������������ ��������� � ����� SmoothAlgorithms.mqh
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+------------------------------------------------+ 
//| ���������� ������������                        |
//+------------------------------------------------+ 
enum Applied_price_ //��� ���������
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+------------------------------------------------+ 
//|  ������� ��������� ����������                  |
//+------------------------------------------------+ 
input string Symbol_="";                               // ���������� �����
input ENUM_TIMEFRAMES Timeframe=PERIOD_H6;             // ��������� ���������� ��� ������� ����������
input uint XLength=20;                                 // ������ ����������
input Applied_price_ IPC=PRICE_CLOSE;                  // ���� ����������
input Smooth_Method XMA_Method=MODE_LWMA;              // ����� ����������
input int XPhase=15;                                   // �������� ����������
//--- ��� JJMA ������������ � �������� -100 ... +100, ������ �� �������� ����������� ��������;
input uint XLength1=5;                                 // ������ ����������� ����������
input Smooth_Method XMA_Method1=MODE_JJMA;             // ����� �����������
input int XPhase1=100;                                 // �������� �����������
//--- XPhase1: ��� JJMA ���������� � �������� -100 ... +100, ������ �� �������� ����������� ��������;
//--- ��������� ����������� ����������� ����������
input uint SignalBar=0;                                // ����� ���� ��� ��������� ������� (0 - ������� ���)
input string Symbols_Sirname=INDICATOR_NAME"_Label_";  // �������� ��� ����� ����������
input color Upsymbol_Color=clrLime;                    // ���� ������� �����
input color Dnsymbol_Color=clrGold;                    // ���� ������� �������
input color IndName_Color=clrDodgerBlue;               // ���� �������� ����������
input uint Symbols_Size=60;                            // ������ �������� �������
input uint Font_Size=10;                               // ������ ������ �������� ����������
input int X_1=5;                                       // �������� �������� �� �����������
input int Y_1=-15;                                     // �������� �������� �� ���������
input bool ShowIndName=true;                           // ����������� �������� ����������
input ENUM_BASE_CORNER  WhatCorner=CORNER_RIGHT_UPPER; // ���� ������������
input uint X_=0;                                       // �������� �� �����������
input uint Y_=20;                                      // �������� �� ���������
//--- ��������� �������
input ENUM_ALERT_MODE alert_mode=OnlySound;            // ������� ��������� ������������
input uint AlertCount=0;                               // ���������� ���������� �������
//+-----------------------------------+
//--- ���������� ������������� ���������� ��� ������� �����������
int Ind_Handle;
//--- ���������� ������������� ���������� ������ ������� ������
int min_rates_total;
//--- ���������� ������������� ���������� ������������ �������� �� ����������� � ���������
uint X_0,Yn,X_1_,Y_1_;
//--- ���������� ���������� ��� ���� �����
string name0,name1,IndName,Symb;
//+------------------------------------------------------------------+
//|  ��������� ���������� � ���� ������                              |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//---
   return(StringSubstr(EnumToString(timeframe),7,-1));
//---
  }
//+------------------------------------------------------------------+
//|  �������� ��������� �����                                        |
//+------------------------------------------------------------------+
void CreateTLabel(long   chart_id,         // ������������� �������
                  string name,             // ��� �������
                  int    nwin,             // ������ ����
                  ENUM_BASE_CORNER corner, // ��������� ���� ��������
                  ENUM_ANCHOR_POINT point, // ��������� ����� ��������
                  int    X,                // ��������� � �������� �� ��� X �� ���� ��������
                  int    Y,                // ��������� � �������� �� ��� Y �� ���� ��������
                  string text,             // �����
                  string textTT,           // ����� ����������� ���������
                  color  Color,            // ���� ������
                  string Font,             // ����� ������
                  int    Size)             // ������ ������
  {
//---
   ObjectCreate(chart_id,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chart_id,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,point);
   ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
   ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,textTT);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true); //������ �� ������ �����
//---
  }
//+------------------------------------------------------------------+
//|  ������������� ��������� �����                                   |
//+------------------------------------------------------------------+
void SetTLabel(long   chart_id,         // ������������� �������
               string name,             // ��� �������
               int    nwin,             // ������ ����
               ENUM_BASE_CORNER corner, // ��������� ���� ��������
               ENUM_ANCHOR_POINT point, // ��������� ����� ��������
               int    X,                // ��������� � �������� �� ��� X �� ���� ��������
               int    Y,                // ��������� � �������� �� ��� Y �� ���� ��������
               string text,             // �����
               string textTT,           // ����� ����������� ���������
               color  Color,            // ���� ������
               string Font,             // ����� ������
               int    Size)             // ������ ������
  {
//---
   if(ObjectFind(chart_id,name)==-1)
     {
      CreateTLabel(chart_id,name,nwin,corner,point,X,Y,text,textTT,Color,Font,Size);
     }
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
     }
//---
  }
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- ������������� ���������� ������ ������� ������  
   int SqrXLength=int(MathFloor(MathSqrt(XLength)));
//--- ������������� ���������� ������ ������� ������
   min_rates_total+=GetStartBars(XMA_Method,XLength,XPhase);
   min_rates_total+=GetStartBars(XMA_Method,SqrXLength,XPhase);
   min_rates_total+=GetStartBars(XMA_Method1,XLength1,XPhase1)+1;
   int ATR_Period=10;
   min_rates_total=int(MathMax(min_rates_total,ATR_Period))+int(SignalBar);
//--- ������������� ����������
   if(Symbol_!="") Symb=Symbol_;
   else Symb=Symbol();
//---
   X_0=X_;
   Yn=Y_+5;
//---
   name0=Symbols_Sirname+"0";
   if(ShowIndName)
     {
      Y_1_=Yn+Y_1;
      X_1_=X_0+X_1;
      name1=Symbols_Sirname+"1";
      StringConcatenate(IndName,INDICATOR_NAME,"(",Symb," ",GetStringTimeframe(Timeframe),")");
     }
//--- ��������� ������ ���������� HullTrendSign
   Ind_Handle=iCustom(Symb,Timeframe,"HullTrendSign",XLength,IPC,XMA_Method,XPhase,XLength1,XMA_Method1,XPhase1,0);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" �� ������� �������� ����� ���������� HullTrendSign");
      return(INIT_FAILED);
     }
//--- ������������� ���������� ��� ��������� ����� ����������
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",XLength,",",IPC,",",XMA_Method,",",XPhase,",",XLength1,",",XMA_Method1,",",XPhase1,")");
//--- �������� ����� ��� ����������� � ��������� ������� � �� ����������� ���������
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- ����������� �������� ����������� �������� ����������
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- ���������� �������������
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void Deinit()
  {
//---
   if(ObjectFind(0,name0)!=-1) ObjectDelete(0,name0);
   if(ObjectFind(0,name1)!=-1) ObjectDelete(0,name1);
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//---
   Deinit();
//---
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // ���������� ������� � ����� �� ������� ����
                const int prev_calculated,// ���������� ������� � ����� �� ���������� ����
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- �������� ���������� ����� �� ������������� ��� �������
   if(BarsCalculated(Ind_Handle)<min_rates_total) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symb,Timeframe)) return(prev_calculated);
//--- ���������� ��������� ����������
   int limit,trend;
   double UpInd[],DnInd[];
   datetime rates_time,TIME[1];
   color Color0=clrNONE;
   string SignSymbol;
   static datetime prev_time;
   static int trend_;
   bool signal=false;
   static uint buycount=0,sellcount=0;
//--- �������� ����� ����������� ������ � �������
   if(CopyTime(Symb,Timeframe,SignalBar,1,TIME)<=0) return(RESET);
//--- ������� ������������ ���������� ���������� ������ ��� ������� CopyBuffer
   if(prev_calculated>rates_total || prev_calculated<=0)// �������� �� ������ ����� ������� ����������
     {
      prev_time=time[0];
      trend_=0;
     }
   rates_time=TimeCurrent();
//--- �������� ����� ����������� ������ � �������
   if(CopyBuffer(Ind_Handle,0,rates_time,prev_time,DnInd)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle,1,rates_time,prev_time,UpInd)<=0) return(RESET);
//--- ������� ���������� ������ limit ��� ����� ��������� �����  
   limit=ArraySize(UpInd)-1;
   trend=trend_;
//--- ���������� ��������� � �������� ��� � ����������  
   ArraySetAsSeries(DnInd,true);
   ArraySetAsSeries(UpInd,true);
//--- ������ �������� ������� � �������� ���������   
   if(TIME[0]!=prev_time && AlertCount)
     {
      buycount=AlertCount;
      sellcount=AlertCount;
     }
//--- �������� ���� ������� ����������
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(UpInd[bar]&&UpInd[bar]!=EMPTY_VALUE) {trend=+1; if(!bar) signal=true;}
      if(DnInd[bar]&&DnInd[bar]!=EMPTY_VALUE) {trend=-1; if(!bar) signal=true;}
      if(bar|| SignalBar) trend_=trend;
     }
//---
   if(trend>0)
     {
      Color0=Upsymbol_Color;
      //---
      if(signal)
        {
         SignSymbol=UP_SIGNAL_SYMBOL;
         if(buycount)
           {
            switch(alert_mode)
              {
               case OnlyAlert: Alert(IndName+": "+BUY_ALERT_TEXT); break;
               case OnlySound: PlaySound(BUY_SOUND); break;
              }
            buycount--;
           }
        }
      else SignSymbol=UP_TREND_SYMBOL;
     }
//---
   if(trend<0)
     {
      Color0=Dnsymbol_Color;
      //---
      if(signal)
        {
         SignSymbol=DN_SIGNAL_SYMBOL;
         if(sellcount)
           {
            switch(alert_mode)
              {
               case OnlyAlert: Alert(IndName+": "+SELL_ALERT_TEXT); break;
               case OnlySound: PlaySound(SELL_SOUND); break;
              }
            sellcount--;
           }
        }
      else SignSymbol=DN_TREND_SYMBOL;
     }
//---
   if(trend)
     {
      if(ShowIndName)
         SetTLabel(0,name1,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_1_,Y_1_,IndName,IndName,IndName_Color,NAMES_SYMBOLS_FONT,Font_Size);
      if(signal) SetTLabel(0,name0,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_0,Yn,SignSymbol,IndName,Color0,SIGNAL_SYMBOLS_FONT,Symbols_Size);
      else SetTLabel(0,name0,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_0,Yn,SignSymbol,IndName,Color0,TREND_SYMBOLS_FONT,Symbols_Size);
     }
   else Deinit();
//---
   ChartRedraw(0);
   prev_time=TIME[0];
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
