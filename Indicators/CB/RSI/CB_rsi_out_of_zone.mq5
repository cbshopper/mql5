//+------------------------------------------------------------------+
//|                                        RSI  Out of Zone.mq5 |
//|
//|                     https://www.mql5.com/ru/market/product/43516 |
//+------------------------------------------------------------------+
#property version   "1.000"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   4
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1     50.0
#property indicator_level2     70.0
#property indicator_level3     30.0
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT
//--- plot Oversold
#property indicator_label1  "Oversold"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Overbought
#property indicator_label2  "Overbought"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- plot RSI
#property indicator_label3 "RSI"
#property indicator_type3  DRAW_LINE
#property indicator_color3 clrBlack
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input int                  Inp_RSI_ma_period    = 14;          // RSI: averaging period
input ENUM_APPLIED_PRICE   Inp_RSI_applied_price = PRICE_CLOSE; // RSI: type of price
input int                  Inp_MA_period        = 100;         // Trend MA Period
input int                  Inp_MA_shift         = 2;           // Trend MA Shift
input int                  Inp_RSO_Level_shift  = 10;          // RSO Level Shift depending on Trend
input int                  Inp_RSI_Level_Down   = 35.0;        // RSI: Value Level Down
input double               Inp_RSI_Level_Up     = 65.0;        // RSI: Value Level Up
//--- indicator buffers
double   OversoldBuffer[];
double   OverboughtBuffer[];
double   iRSIBuffer[];
double   iMABuffer[];
//---
int      handle_iRSI;            // variable for storing the handle of the iRSI indicator
int      bars_calculated = 0;    // we will keep the number of values in the Relative Strength Index indicator
int      handle_iMA;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
   {
//--- indicator buffers mapping
    SetIndexBuffer(0, OversoldBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, OverboughtBuffer, INDICATOR_DATA);
    SetIndexBuffer(3, iMABuffer, INDICATOR_CALCULATIONS);
    SetIndexBuffer(2, iRSIBuffer, INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
    PlotIndexSetInteger(0, PLOT_ARROW, 159);
    PlotIndexSetInteger(1, PLOT_ARROW, 159);
//--- define the symbol code for drawing in PLOT_ARROW
    PlotIndexSetInteger(0, PLOT_ARROW, 233);
    PlotIndexSetInteger(1, PLOT_ARROW, 234);
//--- set the vertical shift of arrows in pixels
    PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 5);
    PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -5);
//--- Set as an empty value 0
    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
    PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
    PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0.0);
    PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0.0);
//--- create handle of the indicator iRSI
    handle_iRSI = iRSI(Symbol(), Period(), Inp_RSI_ma_period, Inp_RSI_applied_price);
//--- if the handle is not created
    if(handle_iRSI == INVALID_HANDLE)
       {
        //--- tell about the failure and output the error code
        PrintFormat("Failed to create handle of the iRSI indicator for the symbol %s/%s, error code %d",
                    Symbol(),
                    EnumToString(Period()),
                    GetLastError());
        //--- the indicator is stopped early
        return(INIT_FAILED);
       }
    handle_iMA = iMA(Symbol(), Period(), Inp_MA_period, Inp_MA_shift, MODE_EMA, Inp_RSI_applied_price);
//--- if the handle is not created
    if(handle_iMA == INVALID_HANDLE)
       {
        //--- tell about the failure and output the error code
        PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                    Symbol(),
                    EnumToString(Period()),
                    GetLastError());
        //--- the indicator is stopped early
        return(INIT_FAILED);
       }
//---
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
    if(rates_total < Inp_RSI_ma_period + 10)
        return(0);
//--- number of values copied from the iRSI indicator
    int values_to_copy;
//--- determine the number of values calculated in the indicator
    int calculated = BarsCalculated(handle_iRSI);
    if(calculated <= 0)
       {
        PrintFormat("BarsCalculated() returned %d, error code %d", calculated, GetLastError());
        return(0);
       }
//--- if it is the first start of calculation of the indicator or if the number of values in the iRSI indicator changed
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
    if(prev_calculated == 0 || calculated != bars_calculated || rates_total > prev_calculated + 1)
       {
        //--- if the iRSIBuffer array is greater than the number of values in the iRSI indicator for symbol/period, then we don't copy everything
        //--- otherwise, we copy less than the size of indicator buffers
        if(calculated > rates_total)
            values_to_copy = rates_total;
        else
            values_to_copy = calculated;
       }
    else
       {
        //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate()
        //--- for calculation not more than one bar is added
        values_to_copy = (rates_total - prev_calculated) + 1;
       }
//--- fill the array with values of the iRSI indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
    if(!FillArrayFromBuffer(iRSIBuffer, handle_iRSI, values_to_copy))
        return(0);
    if(!FillArrayFromBuffer(iMABuffer, handle_iMA, values_to_copy))
        return(0);
//--- memorize the number of values in the Relative Strength Index indicator
    bars_calculated = calculated;
//--- main loop
    int limit = prev_calculated - 1;
    if(prev_calculated == 0)
       {
        for(int i = 0; i <= Inp_RSI_ma_period; i++)
           {
            OversoldBuffer[i] = 0.0;
            OverboughtBuffer[i] = 0.0;
           }
        //limit = MathMax(Inp_RSI_ma_period, Inp_MA_period) + 1;
        limit = Inp_RSI_ma_period + 1;
       }
    for(int i = limit; i < rates_total; i++)
       {
        int trend = 0;
        int level_down = Inp_RSI_Level_Down ;
        int level_up = Inp_RSI_Level_Up ;
        double diff = MathAbs(iMABuffer[i - 1] - iMABuffer[i]) * 100.0 / 100.0;
        double factor = diff * 1 / Point();
        //factor=1;
        if(factor > 1.0)
           {
            //  Print(__FUNCTION__,": factor=",factor);
            if(iMABuffer[i - 1] < iMABuffer[i])   // steigt
               {
                trend = 1;
                level_up = Inp_RSI_Level_Up + Inp_RSO_Level_shift * factor;
                level_down = Inp_RSI_Level_Down + Inp_RSO_Level_shift * factor;
               }
            if(iMABuffer[i - 1] > iMABuffer[i])  // fällt
               {
                trend = -1;
                level_up = Inp_RSI_Level_Up - Inp_RSO_Level_shift;
                level_down = Inp_RSI_Level_Down - Inp_RSO_Level_shift;
               }
            //--- oversold
            if(iRSIBuffer[i - 1] < level_down && iRSIBuffer[i] > level_down)
                OversoldBuffer[i] = iRSIBuffer[i];
            else
                OversoldBuffer[i] = 0.0;
            //--- overboughtBuffer
            if(iRSIBuffer[i - 1] > level_up && iRSIBuffer[i] < level_up)
                OverboughtBuffer[i] = iRSIBuffer[i];
            else
                OverboughtBuffer[i] = 0.0;
           }
       }
//--- return value of prev_calculated for next call
    return(rates_total);
   }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the iRSI indicator                |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &rsi_buffer[],  // indicator buffer of Relative Strength Index values
                         int ind_handle,        // handle of the iRSI indicator
                         int amount             // number of copied values
                        )
   {
//--- reset error code
    ResetLastError();
//--- fill a part of the iRSIBuffer array with values from the indicator buffer that has 0 index
    if(CopyBuffer(ind_handle, 0, 0, amount, rsi_buffer) < 0)
       {
        //--- if the copying fails, tell the error code
        PrintFormat("Failed to copy data from the iRSI indicator, error code %d", GetLastError());
        //--- quit with zero result - it means that the indicator is considered as not calculated
        return(false);
       }
//--- everything is fine
    return(true);
   }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
   {
    if(handle_iRSI != INVALID_HANDLE)
        IndicatorRelease(handle_iRSI);
    if(handle_iMA != INVALID_HANDLE)
        IndicatorRelease(handle_iMA);
//--- clear the chart after deleting the indicator
    Comment("");
   }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
