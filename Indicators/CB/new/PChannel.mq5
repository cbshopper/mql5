//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
#property description "     PChannel"
//----   
#property version   "1.00"
//----     
#property indicator_chart_window
//----        
#property indicator_buffers 9
//----    
#property indicator_plots   4
//+----------------------------------------------+
//|     1            |
//+----------------------------------------------+
//----      
#property indicator_type1   DRAW_FILLING
//----      WhiteSmoke 
#property indicator_color1  clrWhiteSmoke
//----   
#property indicator_label1  "PChannel"
//+----------------------------------------------+
//|     2            |
//+----------------------------------------------+
//----   2   
#property indicator_type2   DRAW_LINE
//----        LightSeaGreen 
#property indicator_color2  clrLightSeaGreen
//----   2 -  
#property indicator_style2  STYLE_SOLID
//----    2  2
#property indicator_width2  2
//----    
#property indicator_label2  "Upper PChannel"
//+----------------------------------------------+
//|     3            |
//+----------------------------------------------+
//----   3   
#property indicator_type3   DRAW_LINE
//----        DeepPink 
#property indicator_color3  clrDeepPink
//----   3 -  
#property indicator_style3  STYLE_SOLID
//----    3  2
#property indicator_width3  2
//----    
#property indicator_label3  "Lower PChannel"
//+----------------------------------------------+
//|     4            |
//+----------------------------------------------+
//----      
#property indicator_type4 DRAW_COLOR_CANDLES
//----     
#property indicator_color4 clrMagenta,clrPurple,clrGray,clrMediumBlue,clrDodgerBlue
//----   - 
#property indicator_style4 STYLE_SOLID
//----     2
#property indicator_width4 2
//----   
#property indicator_label4 "PChannel_BARS"
//+----------------------------------------------+
//|                    |
//+----------------------------------------------+
input uint period=20;  //   
input uint   Shift=2;  //      
//+----------------------------------------------+
//----   ,   
//      
double Up1Buffer[],Dn1Buffer[];
double Up2Buffer[],Dn2Buffer[];
double ExtOpenBuffer[],ExtHighBuffer[],ExtLowBuffer[],ExtCloseBuffer[],ExtColorBuffer[];
//----      
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//----     
   min_rates_total=int(period+1+Shift);

//----      
   SetIndexBuffer(0,Up1Buffer,INDICATOR_DATA);
//----       
   ArraySetAsSeries(Up1Buffer,true);

//----      
   SetIndexBuffer(1,Dn1Buffer,INDICATOR_DATA);
//----       
   ArraySetAsSeries(Dn1Buffer,true);

//----      
   SetIndexBuffer(2,Up2Buffer,INDICATOR_DATA);
//----       
   ArraySetAsSeries(Up2Buffer,true);

//----      
   SetIndexBuffer(3,Dn2Buffer,INDICATOR_DATA);
//----       
   ArraySetAsSeries(Dn2Buffer,true);

//----    IndBuffer   
   SetIndexBuffer(4,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(7,ExtCloseBuffer,INDICATOR_DATA);
//----       
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);

//----     ,    
   SetIndexBuffer(8,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//----       
   ArraySetAsSeries(ExtColorBuffer,true);

//----    1    Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//----       1  min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//----    2    Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//----       2  min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);

//----    3    Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//----       3  min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);

//----    3    Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,0);
//----       4  min_rates_total
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//----   ,      
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);

//----      
   string shortname;
   StringConcatenate(shortname,"PChannel(",period,")");
//---           
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---     
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    //       
                const int prev_calculated,//       
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//----       
   if(rates_total<min_rates_total) return(0);

//----         
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//----   
   int limit;
//----       
   double HH,LL;

//----    limit    
   if(prev_calculated>rates_total || prev_calculated<=0)//      
     {
      limit=rates_total-min_rates_total; //      
     }
   else
     {
      limit=rates_total-prev_calculated; //      
     }

//----    
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      HH=high[ArrayMaximum(high,bar,period)];
      LL=low[ArrayMinimum(low,bar,period)];
      Up1Buffer[bar]=HH;
      Dn1Buffer[bar]=LL;
      Up2Buffer[bar]=HH;
      Dn2Buffer[bar]=LL;
     }

//----    limit    
   if(prev_calculated>rates_total || prev_calculated<=0) limit-=int(Shift);
//----     
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      int clr=2;
      ExtOpenBuffer[bar]=0.0;
      ExtCloseBuffer[bar]=0.0;
      ExtHighBuffer[bar]=0.0;
      ExtLowBuffer[bar]=0.0;

      if(close[bar]>Up1Buffer[bar+Shift])
        {
         if(open[bar]<=close[bar]) clr=4;
         else clr=3;
         ExtOpenBuffer[bar]=open[bar];
         ExtCloseBuffer[bar]=close[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
        }

      if(close[bar]<Dn1Buffer[bar+Shift])
        {
         if(open[bar]>close[bar]) clr=0;
         else clr=1;
         ExtOpenBuffer[bar]=open[bar];
         ExtCloseBuffer[bar]=close[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
        }
        
      ExtColorBuffer[bar]=clr;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+