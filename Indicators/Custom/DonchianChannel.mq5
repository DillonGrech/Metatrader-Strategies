//+------------------------------------------------------------------+
//|                                             Donchian_Channel.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//| Resource:                                                        |
//| https://www.mql5.com/en/articles/12711                           |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Donchian Channel"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 3
#property indicator_color1  OrangeRed //Upper
#property indicator_color2  Orange    //Mid
#property indicator_color3  OrangeRed //Lower

//--- input params
input int indPeriod=20; //Period

//--- indicator buffer
double UpperBuffer[];
double MiddleBuffer[];
double LowerBuffer[];

//--- indicator variables
double upperLine,lowerLine,middleLine;
int start, bar;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   //indicator buffers mapping
   indInit(0,UpperBuffer,"Upper Donchian",indicator_color1);
   indInit(1,MiddleBuffer,"Middle Donchian",indicator_color2);
   indInit(2,LowerBuffer,"Lower Donchian",indicator_color3);
   IndicatorSetString(INDICATOR_SHORTNAME,"Donchian ("+IntegerToString(indPeriod)+")");

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
   if(rates_total<indPeriod+1)
     {
      return 0;
     }
   start=prev_calculated==0? indPeriod: prev_calculated-1;
   for(bar=start;bar<rates_total;bar++)
   {
      upperLine=high[ArrayMaximum(high,bar-indPeriod+1,indPeriod)];
      lowerLine=low[ArrayMinimum(low,bar-indPeriod+1,indPeriod)];
      middleLine=(upperLine+lowerLine)/2;
      
      LowerBuffer[bar]=upperLine-(upperLine-lowerLine);
      UpperBuffer[bar]=lowerLine+(upperLine-lowerLine);
      MiddleBuffer[bar]=middleLine;
   }

   //return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
// Function to set up indicator buffer and plots
void indInit(int index, double &buffer[],string label, color IndicatorColor)
  {
   SetIndexBuffer(index,buffer,INDICATOR_DATA);
   PlotIndexSetInteger(index,PLOT_DRAW_TYPE,DRAW_LINE);
   PlotIndexSetInteger(index,PLOT_LINE_WIDTH,2);
   PlotIndexSetInteger(index,PLOT_DRAW_BEGIN,indPeriod-1);
   PlotIndexSetInteger(index,PLOT_SHIFT,1);
   PlotIndexSetInteger(index,PLOT_LINE_COLOR,IndicatorColor);
   PlotIndexSetString(index,PLOT_LABEL,label);
   PlotIndexSetDouble(index,PLOT_EMPTY_VALUE,EMPTY_VALUE);
  }

//+------------------------------------------------------------------+