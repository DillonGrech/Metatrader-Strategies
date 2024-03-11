//+------------------------------------------------------------------+
//|                                        IndicatorLibrary-v1p1.mq5 |
//|                                    Copyright 2024, Dillon Grech. |
//|                   YouTube: https://www.youtube.com/c/DillonGrech |
//|                           GitHub: https://github.com/DillonGrech |
//|                           Discord: https://discord.gg/xs3KpdUjSu |
//+------------------------------------------------------------------+
//|                                                  Version Notes 1 |
//| This file contains a list of indicators which can be used for    |
//| triggers (entry or exit triggers), filters and getting indicator |
//| values.                                                          |
//|                                                                  |
//+------------------------------------------------------------------+
//|                                                    Patch Notes 1 |
//| Patch version 1 is a template file for those following along     |
//| in my youtube tutorial. Completed version will be released as    |
//| patch version 2.                                                 |
//|                                                                  |
//+------------------------------------------------------------------+
//|                                                            NOTES |
//| STRUCTURE                                                        |
//|                                                                  |
//| LEGEND                                                           |
//|                                                                  |
//| EXAMPLE                                                          |
//|                                                                  |
//| LIBRARY CONTENTS                                                 |
//|---TREND FOLLOWING INDICATORS                                     |
//|                                                                  |
//|---MOMENTUM INDICATORS                                            |
//|                                                                  |
//|---VOLATILITY INDICATORS                                          |
//|                                                                  |
//|---OSCILLATOR INDICATORS                                          |
//|                                                                  |
//|---PRICE ACTION INDICATORS                                        |
//|                                                                  |
//|---OTHER INDICATORS                                               |
//|                                                                  |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2024, Dillon Grech"
#property version   "1.01"
//+------------------------------------------------------------------+
//| Set up Inidcator Handle                                          |
//+------------------------------------------------------------------+
int GetIndicatorHandle(string Indicator, string CurrentSymbol, ENUM_TIMEFRAMES CurrentPeriod) export
{
//---SET UP
//---CHECK FOR NA INDICATOR
//---TREND FOLLOWING INDICATORS
//---MOMENTUM INDICATORS
//---VOLATILITY INDICATORS
//---OSCILLATOR INDICATORS
//---PRICE ACTION INDICATORS
//---OTHER INDICATORS
//---ERROR HANDLING
   return   0;
}
//+------------------------------------------------------------------+
//Set up Indicator Trigger Signals
//+------------------------------------------------------------------+
string GetIndicatorTrigger(string Indicator, int IndicatorHandle, string CurrentSymbol, ENUM_TIMEFRAMES CurrentPeriod) export
{
//---SET UP
//---CHECK FOR NA INDICATOR
//---TREND FOLLOWING INDICATORS
//---MOMENTUM INDICATORS
//---VOLATILITY INDICATORS
//---OSCILLATOR INDICATORS
//---PRICE ACTION INDICATORS
//---OTHER INDICATORS
//---ERROR HANDLING
   return   "Error";
}
//+------------------------------------------------------------------+
//| Set up Indicator Filter Signals                                  |
//+------------------------------------------------------------------+
string GetIndicatorFilter(string Indicator, int IndicatorHandle, string CurrentSymbol, ENUM_TIMEFRAMES CurrentPeriod) export
{
//---SET UP
//---CHECK FOR NA INDICATOR
//---TREND FOLLOWING INDICATORS
//---MOMENTUM INDICATORS
//---VOLATILITY INDICATORS
//---OSCILLATOR INDICATORS
//---PRICE ACTION INDICATORS
//---OTHER INDICATORS
//---ERROR HANDLING
   return   "Error";
}
//+------------------------------------------------------------------+
//| Get Indicator Value                                              |
//+------------------------------------------------------------------+
//Get indicator value from handle and indicator buffer value to be returned
double GetIndicatorValue(int IndicatorHandle, int BufferValue) export
{
   return(0.0);
}
//+------------------------------------------------------------------+