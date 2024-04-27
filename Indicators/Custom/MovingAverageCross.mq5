//+------------------------------------------------------------------+
//|                                  Custom Moving Average Cross.mq5 |
//|                             Copyright 2000-2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2000-2024, MetaQuotes Ltd."
#property link        "https://www.mql5.com"
#property description "Custom Moving Average Cross"

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_color1  Aqua
#property indicator_type2   DRAW_LINE
#property indicator_color2  Red
#property indicator_label1  "Fast MA"
#property indicator_label2  "Slow MA"
//--- input parameters
input ENUM_MA_METHOD InpMAMethod=MODE_SMMA;  // Method
input int            InpFastMAPeriod=13;     // Period
input int            InpSlowMAPeriod=26;     // Period
input ENUM_APPLIED_PRICE InpAppliedPrice=PRICE_CLOSE; // Applied price
//--- indicator buffer
double ExtFastMaBuffer[];
double ExtSlowMaBuffer[];
//--- indicator Handle
int    ExtFastMaHandle;
int    ExtSlowMaHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtFastMaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtSlowMaBuffer,INDICATOR_DATA);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- set first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpSlowMAPeriod);
//--- name for DataWindow and MA values
   string short_name;
   switch(InpMAMethod)
     {
      case MODE_EMA :
         short_name="EmaX";
         ExtFastMaHandle=iMA(NULL,0,InpFastMAPeriod,0,MODE_EMA,InpAppliedPrice);
         ExtSlowMaHandle=iMA(NULL,0,InpSlowMAPeriod,0,MODE_EMA,InpAppliedPrice);
         break;
      case MODE_LWMA :
         short_name="LwmaX";
         ExtFastMaHandle=iMA(NULL,0,InpFastMAPeriod,0,MODE_LWMA,InpAppliedPrice);
         ExtSlowMaHandle=iMA(NULL,0,InpSlowMAPeriod,0,MODE_LWMA,InpAppliedPrice);         
         break;
      case MODE_SMA :
         short_name="SmaX";
         ExtFastMaHandle=iMA(NULL,0,InpFastMAPeriod,0,MODE_SMA,InpAppliedPrice);
         ExtSlowMaHandle=iMA(NULL,0,InpSlowMAPeriod,0,MODE_SMA,InpAppliedPrice);         
         break;
      case MODE_SMMA :
         short_name="SmmaX";
         ExtFastMaHandle=iMA(NULL,0,InpFastMAPeriod,0,MODE_SMMA,InpAppliedPrice);
         ExtSlowMaHandle=iMA(NULL,0,InpSlowMAPeriod,0,MODE_SMMA,InpAppliedPrice);         
         break;
      default :
         short_name="unknown MaX";
     }
   IndicatorSetString(INDICATOR_SHORTNAME,short_name+"("+string(InpFastMAPeriod)+" " +string(InpSlowMAPeriod)+")");
//--- set drawing line empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
  }
//+------------------------------------------------------------------+
//|  Moving Average                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
  if(rates_total<InpSlowMAPeriod-1+begin)
      return(0);

//--- not all data may be calculated
   int calculated=BarsCalculated(ExtFastMaHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtFastMaHandle is calculated (",calculated," bars). Error ",GetLastError());
      return(0);
     }
   calculated=BarsCalculated(ExtSlowMaHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtSlowMaHandle is calculated (",calculated," bars). Error ",GetLastError());
      return(0);
     }      
//--- we can copy not all data
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0)
      to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0)
         to_copy++;
     }      
//--- get Fast MA buffer
   if(IsStopped()) // checking for stop flag
      return(0);
   if(CopyBuffer(ExtFastMaHandle,0,0,to_copy,ExtFastMaBuffer)<=0)
     {
      Print("Getting fast MA is failed! Error ",GetLastError());
      return(0);
     }
//--- get Slow MA buffer
   if(IsStopped()) // checking for stop flag
      return(0);
   if(CopyBuffer(ExtSlowMaHandle,0,0,to_copy,ExtSlowMaBuffer)<=0)
     {
      Print("Getting slow MA is failed! Error ",GetLastError());
      return(0);
     }

//--- return value of prev_calculated for next call
   return(rates_total);  
  }