//+------------------------------------------------------------------+
//|                                      MACD-EMA-Strategy-v1.01.mq5 |
//|                                                     Dillon Grech |
//|                                             https://www.mql5.com |
//|                            https://www.youtube.com/c/DillonGrech |
//|            https://github.com/Dillon-Grech/Metatrader-Strategies |
//+------------------------------------------------------------------+
//|                                                  Version Notes 1 |
//| Introduction into MQL5. Expert Advisor demonstrates OnInit (),   |
//| OnDeinit () & OnTick () functions. Advisor adds in key Global    |
//| functions which are commonly used. This can be commonly used as  |
//| a template file.                                                 |
//+------------------------------------------------------------------+
//|                                                    Patch Notes 1 |
//| NA                                                               |
//|                                                                  |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Dillon Grech"
#property link      "https://www.mql5.com"
#property version   "1.01"

//Include Functions
#include <Trade\Trade.mqh> //Include MQL trade object functions
CTrade   *Trade;           //Declaire Trade as pointer to CTrade class

//Setup Variables
input int                InpMagicNumber  = 2000001;     //Unique identifier for this expert advisor
input string             InpTradeComment = __FILE__;    //Optional comment for trades
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_CLOSE; //Applied price for indicators

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
