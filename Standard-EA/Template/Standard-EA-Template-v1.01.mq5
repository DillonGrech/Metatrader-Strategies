//+------------------------------------------------------------------+
//|                                   Standard-EA-Tempalte-v1.01.mq5 |
//|                                    Copyright 2023, Dillon Grech. |
//|                                             https://www.mql5.com |
//|                   YouTube: https://www.youtube.com/c/DillonGrech |
//|                           GitHub: https://github.com/DillonGrech |
//|                           Discord: https://discord.gg/xs3KpdUjSu |
//+------------------------------------------------------------------+
//|                                                  Version Notes 1 |
//| This file is used as a template for standard or single-symbol    |
//| expert advisors. Template uses a Trigger indicator and 2x filter |
//| indicators for conditions. Money Management is basic only with   |
//| static TP/SL and position size.                                  |
//+------------------------------------------------------------------+
//|                                                    Patch Notes 1 |
//| NA                                                               |
//|                                                                  |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
//|                                              Strategy Conditions |
//| NA                                                               |
//|                                                                  |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Copyright 2023, Dillon Grech"
#property version   "1.01"

//+------------------------------------------------------------------+
//| Expert Setup                                                     |
//+------------------------------------------------------------------+

//Libraries and Setup
#include  <Trade\Trade.mqh> //Include MQL trade object functions
CTrade    *Trade;           //Declaire Trade as pointer to CTrade class
input int  InpMagicNumber  = 2000001;     //Unique identifier for this expert advisor





//Global Variables
int TicksReceivedCount = 0; //Counts the number of ticks from oninit function

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Print("Hello World - OnInit Function");
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   //Declare Variables     
   TicksReceivedCount++; //Counts the number of ticks received
    
   //Comment for user
   Comment("\n\rExpert: ", InpMagicNumber, "\n\r",
            "MT5 Server Time: ", TimeCurrent(), "\n\r",
            "Ticks Received: ", TicksReceivedCount,"\n\r\n\r",
            "Symbols Traded: \n\r", 
            Symbol());
  }
//+------------------------------------------------------------------+
