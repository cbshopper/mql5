//+------------------------------------------------------------------+
//|                                                          HMA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "Alan Hull's Moving Average"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot HMA
#property indicator_label1  "Hull MA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrFireBrick
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input uint                 InpPeriod         =  20;            // Period
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   // Applied price
//--- indicator buffers
double         BufferHMA[];
double         BufferRAW[];
double         BufferMAP[];
double         BufferMAL[];
//--- global variables
int            period_ma;
int            period_l2;
int            period_sqrt;
int            handle_maP;
int            handle_maL;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables
   period_ma=int(InpPeriod<4 ? 4 : InpPeriod);
   period_l2=(int)floor(double(period_ma)/2.0);
   period_sqrt=(int)floor(sqrt(double(period_ma)))-1;
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferHMA,INDICATOR_DATA);
   SetIndexBuffer(1,BufferRAW,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,BufferMAP,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,BufferMAL,INDICATOR_CALCULATIONS);
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"HullMA("+(string)period_ma+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(BufferHMA,true);
   ArraySetAsSeries(BufferRAW,true);
   ArraySetAsSeries(BufferMAP,true);
   ArraySetAsSeries(BufferMAL,true);
//--- create MA's handle
   ResetLastError();
   handle_maP=iMA(NULL,PERIOD_CURRENT,period_ma,0,MODE_LWMA,InpAppliedPrice);
   if(handle_maP==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_ma,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
   handle_maL=iMA(NULL,PERIOD_CURRENT,period_l2,0,MODE_LWMA,InpAppliedPrice);
   if(handle_maL==INVALID_HANDLE)
     {
      Print("The iMA(",(string)period_l2,") object was not created: Error ",GetLastError());
      return INIT_FAILED;
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<period_ma) return 0;
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-period_ma-1;
      ArrayInitialize(BufferHMA,EMPTY_VALUE);
      ArrayInitialize(BufferRAW,0);
      ArrayInitialize(BufferMAP,0);
      ArrayInitialize(BufferMAL,0);
     }
//--- Подготовка данных
   int copied=0,count=(limit==0 ? 1 : rates_total);
   copied=CopyBuffer(handle_maP,0,0,count,BufferMAP);
   if(copied!=count) return 0;
   copied=CopyBuffer(handle_maL,0,0,count,BufferMAL);
   if(copied!=count) return 0;
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferRAW[i]=2*BufferMAL[i]-BufferMAP[i];
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
      BufferHMA[i]=MAOnArray(BufferRAW,0,period_sqrt,0,MODE_LWMA,i);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| iMAOnArray() https://www.mql5.com/ru/articles/81                 |
//+------------------------------------------------------------------+
double MAOnArray(double &array[],int total,int period,int ma_shift,int ma_method,int shift)
  {
   double buf[],arr[];
   if(total==0) total=ArraySize(array);
   if(total>0 && total<=period) return(0);
   if(shift>total-period-ma_shift) return(0);
//---
   switch(ma_method)
     {
      case MODE_SMA :
        {
         total=ArrayCopy(arr,array,0,shift+ma_shift,period);
         if(ArrayResize(buf,total)<0) return(0);
         double sum=0;
         int    i,pos=total-1;
         for(i=1;i<period;i++,pos--)
            sum+=arr[pos];
         while(pos>=0)
           {
            sum+=arr[pos];
            buf[pos]=sum/period;
            sum-=arr[pos+period-1];
            pos--;
           }
         return(buf[0]);
        }
      case MODE_EMA :
        {
         if(ArrayResize(buf,total)<0) return(0);
         double pr=2.0/(period+1);
         int    pos=total-2;
         while(pos>=0)
           {
            if(pos==total-2) buf[pos+1]=array[pos+1];
            buf[pos]=array[pos]*pr+buf[pos+1]*(1-pr);
            pos--;
           }
         return(buf[shift+ma_shift]);
        }
      case MODE_SMMA :
        {
         if(ArrayResize(buf,total)<0) return(0);
         double sum=0;
         int    i,k,pos;
         pos=total-period;
         while(pos>=0)
           {
            if(pos==total-period)
              {
               for(i=0,k=pos;i<period;i++,k++)
                 {
                  sum+=array[k];
                  buf[k]=0;
                 }
              }
            else sum=buf[pos+1]*(period-1)+array[pos];
            buf[pos]=sum/period;
            pos--;
           }
         return(buf[shift+ma_shift]);
        }
      case MODE_LWMA :
        {
         if(ArrayResize(buf,total)<0) return(0);
         double sum=0.0,lsum=0.0;
         double price;
         int    i,weight=0,pos=total-1;
         for(i=1;i<=period;i++,pos--)
           {
            price=array[pos];
            sum+=price*i;
            lsum+=price;
            weight+=i;
           }
         pos++;
         i=pos+period;
         while(pos>=0)
           {
            buf[pos]=sum/weight;
            if(pos==0) break;
            pos--;
            i--;
            price=array[pos];
            sum=sum-lsum+price*period;
            lsum-=array[i];
            lsum+=price;
           }
         return(buf[shift+ma_shift]);
        }
      default: return(0);
     }
   return(0);
  }
//+------------------------------------------------------------------+