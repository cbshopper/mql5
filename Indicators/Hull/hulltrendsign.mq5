//+---------------------------------------------------------------------+
//|                                                   HullTrendSign.mq5 |
//|                                        Copyright © 2005, adoleh2000 |
//|                                                adoleh2000@yahoo.com |
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property  copyright "Copyright © 2005, adoleh2000."
#property  link      "adoleh2000@yahoo.com"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован Red цвет
#property indicator_color1  clrRed
//--- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//--- отображение бычей метки индикатора
#property indicator_label1  "HullTrendSign Sell"
//+----------------------------------------------+
//| Параметры отрисовки бычьго индикатора        |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычей линии индикатора использован LimeGreen цвет
#property indicator_color2  clrLimeGreen
//--- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//--- отображение медвежьей метки индикатора
#property indicator_label2 "HullTrendSign Buy"
//+----------------------------------------------+
//| Описание класса CXMA                         |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//--- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2,XMA3,XMA4;
//+----------------------------------------------+
//| объявление перечислений                      |
//+----------------------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
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
//+----------------------------------------------+
//| объявление перечислений                      |
//+----------------------------------------------+
enum Applied_price_ //Тип константы
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
//+----------------------------------------------+
//| объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint XLength=20;                           // Период индикатора
input Applied_price_ IPC=PRICE_CLOSE;            // Цена индикатора
input Smooth_Method XMA_Method=MODE_LWMA;        // Метод усреднения
input int XPhase=15;                             // Параметр усреднения
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
input uint XLength1=5;                           // Период сглаживания индикатора
input Smooth_Method XMA_Method1=MODE_JJMA;       // Метод сглаживания
input int XPhase1=100;                           // Параметр сглаживания
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
input int Shift=0;                               // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double SellBuffer[];
double BuyBuffer[];
//--- объявление целочисленных переменных начала отсчета данных
int  min_rates_1,min_rates_2,min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle;
int XLength2,SqrXLength;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация переменных   
   XLength2=int(XLength/2);
   SqrXLength=int(MathFloor(MathSqrt(XLength)));
//--- инициализация переменных начала отсчета данных
   min_rates_1=XMA1.GetStartBars(XMA_Method,XLength,XPhase);
   min_rates_2=min_rates_1+XMA1.GetStartBars(XMA_Method,SqrXLength,XPhase);
   min_rates_total=min_rates_2+XMA1.GetStartBars(XMA_Method1,XLength1,XPhase1)+1;
   int ATR_Period=10;
   min_rates_total=int(MathMax(min_rates_total,ATR_Period));
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,84);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,84);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"HullTrendSign");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  { 
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- объявления локальных переменных 
   int first,bar;
//--- объявление переменных с плавающей точкой  
   double price,xma,xma2,hma,xhma,osma,xosma,trend,ATR[1];
   static double xosma1,trend1;
//--- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      first=0; // стартовый номер для расчета всех баров
      trend1=0;
      xosma1=0;
     }
   else first=prev_calculated-1; // стартовый номер для расчета новых баров
//--- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price=PriceSeries(IPC,bar,open,low,high,close);
      xma2=XMA1.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength2,price,bar,false);
      xma=XMA2.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,XLength,price,bar,false);
      hma=2*xma2-xma;
      xhma=XMA3.XMASeries(min_rates_1,prev_calculated,rates_total,XMA_Method,XPhase,SqrXLength,hma,bar,false);     
      osma=hma-xhma;
      xosma=XMA4.XMASeries(min_rates_2,prev_calculated,rates_total,XMA_Method1,XPhase1,XLength1,osma,bar,false);      
      trend=xosma-xosma1;
//---      
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //---
      if(trend1<=0 && trend>0)
        {
         //--- копируем вновь появившиеся данные в массив
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         BuyBuffer[bar]=low[bar]-ATR[0]*3/8;
        }
      //---
      if(trend1>=0 && trend<0)
        {
         //--- копируем вновь появившиеся данные в массив
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         SellBuffer[bar]=high[bar]+ATR[0]*3/8;
        }
      //---
      if(bar<rates_total-1)
       {
        trend1=trend;
        xosma1=xosma;
       }
     }
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
