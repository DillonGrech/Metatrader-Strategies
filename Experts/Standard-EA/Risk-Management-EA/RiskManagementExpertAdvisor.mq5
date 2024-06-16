//+------------------------------------------------------------------+
//|                                  RiskManagementExpertAdvisor.mq5 |
//|                                    Copyright 2024, Dillon Grech. |
//|                   YouTube: https://www.youtube.com/c/DillonGrech |
//|                           GitHub: https://github.com/DillonGrech |
//|                           Discord: https://discord.gg/xs3KpdUjSu |
//+------------------------------------------------------------------+
//|                                                  Version Notes 1 |
//| This expert advisor uses the RiskLibrary file to perform risk    |
//| calculations for 3 key scenerios.                                |
//|                                                                  |
//+------------------------------------------------------------------+
//|                                                    Patch Notes 1 |
//| Coded as part of YouTube tutorial                                |
//|                                                                  |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Libraries                                                        |
//+------------------------------------------------------------------+
#import   "RiskLibrary.ex5"
   double GetRiskAmount(string CurrentSymbol, double EntryPrice,  double StopLossPrice, double RiskLots);
   double GetRiskLots(string CurrentSymbol, double EntryPrice, double StopLossPrice, double RiskAmount);
   double GetStopLoss(string CurrentSymbol, double EntryPrice, ENUM_ORDER_TYPE OrderType, double RiskLots, double RiskAmount);
#import

//+------------------------------------------------------------------+
//| Expert Setup                                                     |
//+------------------------------------------------------------------+
//Declare variables
string CurrentSymbol            = Symbol();
input double RiskLots           = 0.60;    //Lot size
input double RiskAmount         = 100;     //Risk amount in base currency
input double EntryPrice         = 1.00075; //Entry Price
input double StopLossPrice      = 1.00000; //Stop Price
input ENUM_ORDER_TYPE OrderType = ORDER_TYPE_BUY;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{

   Print("Account Currency is: ", AccountInfoString(ACCOUNT_CURRENCY));
   Print("Testing for symbol: ", CurrentSymbol);
      
   //1. Find the optimal risk amount using risk distance in points (from entry price and stop loss price) and lot size  
   double CalcRiskAmount    = GetRiskAmount(CurrentSymbol, EntryPrice, StopLossPrice, RiskLots);

   //2. Find the optimal lot size using risk distance in points (from entry price and stop loss price) and risk amount    
   double CalcRiskLots      = GetRiskLots(CurrentSymbol, EntryPrice, StopLossPrice, RiskAmount);

   //3. Find the optimal risk distance in points using lot size and risk amount, then find the optimal stop loss    
   double CalcStopLossPrice = GetStopLoss(CurrentSymbol, EntryPrice, OrderType, RiskLots, RiskAmount);

   //Return initialization completed
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+