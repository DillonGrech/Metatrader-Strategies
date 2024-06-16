//+------------------------------------------------------------------+
//|                                                  RiskLibrary.mq5 |
//|                                    Copyright 2024, Dillon Grech. |
//|                   YouTube: https://www.youtube.com/c/DillonGrech |
//|                           GitHub: https://github.com/DillonGrech |
//|                           Discord: https://discord.gg/xs3KpdUjSu |
//+------------------------------------------------------------------+
//|                                                  Version Notes 1 |
//| This file contains the required functions for an expert advisor  |
//| to process trading signals.                                      |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
//|                                                    Patch Notes 1 |
//| Coded as part of YouTube tutorial                                |
//|                                                                  |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property library
#property copyright "Copyright 2024, Dillon Grech"
#property version   "1.01"

#include  <Trade\Trade.mqh> //Include MQL trade object functions
CTrade    *Trade;           //Declaire Trade as pointer to CTrade class

//+------------------------------------------------------------------+
//| Get Point Value for Positions                                    |
//+------------------------------------------------------------------+
//0. Find the value in account currency of a one point move for the current symbol being traded
double GetPointValue(string CurrentSymbol)
{
   double TickSize      = SymbolInfoDouble(CurrentSymbol,SYMBOL_TRADE_TICK_SIZE);
   double TickValue     = SymbolInfoDouble(CurrentSymbol,SYMBOL_TRADE_TICK_VALUE);
   double PointAmount   = SymbolInfoDouble(CurrentSymbol,SYMBOL_POINT);
   double TicksPerPoint = TickSize/PointAmount;    //Ensure that symbol tick size is same as point size; typically equal to 1
   double PointValue    = TickValue/TicksPerPoint; //Return the size of a single point
   
   //Print
   Print("0. Tick Size: ",  TickSize,
      " Tick Value: ",      TickValue,
      " Point Amount: ",    PointAmount,
      " Ticks Per Point: ", TicksPerPoint,
      " Point Value: ",     PointValue);
   
   //Return value
   return (PointValue);
}

//+------------------------------------------------------------------+
//| Get Risk Amount from risk lots and stop loss price               |
//+------------------------------------------------------------------+
//1. Find the optimal risk amount using lot size and risk points (from entry price and stop loss price)
double GetRiskAmount(string CurrentSymbol, double EntryPrice,  double StopLossPrice, double RiskLots) export
{  
   double PointAmount   = SymbolInfoDouble(CurrentSymbol,SYMBOL_POINT);
   double PointValue    = GetPointValue(CurrentSymbol);
   double RiskPoints    = MathAbs((EntryPrice-StopLossPrice)/PointAmount);
   double RiskAmount    = NormalizeDouble((RiskPoints*RiskLots*PointValue),2);
   
   //Print
   Print("1. Symbol: ", CurrentSymbol, 
      " Entry Price: ", EntryPrice,
      " Stop Price: ",  StopLossPrice,
      " Risk Points: ", RiskPoints, 
      " Risk Lots: ",   RiskLots, 
      " Risk Amount: ", RiskAmount);   
   
   //Return value
   return(RiskAmount);
}

//+------------------------------------------------------------------+
//| Get Lot Size                                                     |
//+------------------------------------------------------------------+
//2. Find the optimal lot size using risk amount and risk points (from entry price and stop loss price)
double GetRiskLots(string CurrentSymbol, double EntryPrice, double StopLossPrice, double RiskAmount) export
{
   double PointAmount   = SymbolInfoDouble(CurrentSymbol,SYMBOL_POINT);   
   double PointValue    = GetPointValue(CurrentSymbol);
   double RiskPoints    = MathAbs((EntryPrice-StopLossPrice)/PointAmount);
   double RiskLots      = NormalizeDouble(RiskAmount/(RiskPoints*PointValue),2);
   
   //Print
   Print("2. Symbol: ", CurrentSymbol, 
      " Entry Price: ", EntryPrice,
      " Stop Price: ",  StopLossPrice,   
      " Risk Amount: ", RiskAmount,
      " Risk Points: ", RiskPoints,
      " Risk Lots: ",   RiskLots);
   
   //Return value
   return (RiskLots);
}

//+------------------------------------------------------------------+
//| Get Stop Loss                                                    |
//+------------------------------------------------------------------+
//3. Find the optimal risk distance in points using lot size and risk amount, then find the optimal stop loss   
double GetStopLoss(string CurrentSymbol, double EntryPrice, ENUM_ORDER_TYPE OrderType, double RiskLots,  double RiskAmount) export
{
   double StopLossPrice = 0.0;
   int    SymbolDigits  = (int) SymbolInfoInteger(CurrentSymbol,SYMBOL_DIGITS);
   double PointAmount   = SymbolInfoDouble(CurrentSymbol,SYMBOL_POINT); 
   double PointValue    = GetPointValue(CurrentSymbol);
   double RiskPoints    = NormalizeDouble(RiskAmount/(RiskLots*PointValue),2); 
   if(OrderType == ORDER_TYPE_BUY)
      StopLossPrice = NormalizeDouble((EntryPrice - (RiskPoints*PointAmount)),SymbolDigits);
   else if(OrderType == ORDER_TYPE_SELL)   
      StopLossPrice = NormalizeDouble((EntryPrice + (RiskPoints*PointAmount)),SymbolDigits);
   else
      StopLossPrice = 0.0;
   
   //Print
   Print("3. Symbol: ", CurrentSymbol, 
      " Risk Lots: ",   RiskLots, 
      " Risk Amount: ", RiskAmount,
      " Risk Points: ", RiskPoints,
      " Entry Price: ", EntryPrice,
      " Stop Price: ",  StopLossPrice);     
   
   //Return value
   return (StopLossPrice);
}

//+------------------------------------------------------------------+
//| Initiate MQL trade functions                                     |
//+------------------------------------------------------------------+
//Initiate cTrade and magic number
void InitiateTrade(int MagicNumber) export
{   
   Trade = new CTrade();
   Trade.SetExpertMagicNumber(MagicNumber);
   
   //Print
   Print("Trade Library Inititated");
   
   //Return value
   return;  
}

//+------------------------------------------------------------------+
//| Process trades                                                   |
//+------------------------------------------------------------------+
ulong ProcessTradeOpen(string CurrentSymbol, ENUM_ORDER_TYPE OrderType, int MagicNumber, double RiskLots, double EntryPrice, double StopLossPrice, double TakeProfitPrice) export
{
   //Calculate Risk Amount for user
   double RiskAmount = GetRiskAmount(CurrentSymbol, EntryPrice, StopLossPrice, RiskLots);
   
   //Close any current positions and open new position
   Trade.PositionClose(CurrentSymbol);
   Trade.SetExpertMagicNumber(MagicNumber);  
   Trade.PositionOpen(CurrentSymbol,OrderType,RiskLots,EntryPrice,StopLossPrice,TakeProfitPrice,__FILE__);
   
   //Get Position Ticket Number - run through open positions and store ticket number whcih matches with current symbol
   //Note - history deals total does not work for multisymbol
   ulong  Ticket = 0;
   int Total = PositionsTotal();
   for (int i=Total -1; i>=0; i--)
      {
         ulong GetTicket  = PositionGetTicket(i);
         string GetSymbol = PositionGetSymbol(i);
         if (CurrentSymbol == GetSymbol)
            Ticket = GetTicket;
      }
   
   //Print successful
   Print("Trade Processed For Ticket ", Ticket, " Symbol ", CurrentSymbol," OrderType ",OrderType, " Risk Lots ", RiskLots, " Risk Amount ", RiskAmount);
   
   return(Ticket);
}

//+------------------------------------------------------------------+
//| Get Price                                                        |
//+------------------------------------------------------------------+
//Set symbol string and variables 
double GetPrice(string CurrentSymbol, ENUM_ORDER_TYPE OrderType) export
{
   int    SymbolDigits    = (int) SymbolInfoInteger(CurrentSymbol,SYMBOL_DIGITS); //note - typecast required to remove error
   double Price           = 0.0;
   //Open buy or sell orders
   if(OrderType == ORDER_TYPE_BUY)
      Price = NormalizeDouble(SymbolInfoDouble(CurrentSymbol, SYMBOL_ASK), SymbolDigits);
   else if(OrderType == ORDER_TYPE_SELL)
      Price = NormalizeDouble(SymbolInfoDouble(CurrentSymbol, SYMBOL_BID), SymbolDigits);
   else
      Price = 0.0;   
   
   //Print
   Print("Price = ",Price);
   
   //Return value
   return(Price);   
}


//+------------------------------------------------------------------+
//| Process trades close                                             |
//+------------------------------------------------------------------+
void ProcessTradeClose(string CurrentSymbol, ulong Ticket) export
{
   Trade.PositionClose(Ticket);
   
   //Print
   Print("Trade Closed For Ticket ", Ticket, " Symbol ", CurrentSymbol);
   
   //Return value
   return;
}

//+------------------------------------------------------------------+
//| Get Take Profit Using Risk Reward Ratio                          |
//+------------------------------------------------------------------+
double GetTakeProfit(string CurrentSymbol, ENUM_ORDER_TYPE OrderType, double EntryPrice, double StopLossPrice, double RiskReward) export
{
   int    SymbolDigits     = (int) SymbolInfoInteger(CurrentSymbol,SYMBOL_DIGITS);
   double StopLossDistance = MathAbs(EntryPrice - StopLossPrice);
   
   double TakeProfitPrice = 0.0;
   if(OrderType == ORDER_TYPE_BUY)
      TakeProfitPrice = NormalizeDouble(EntryPrice + RiskReward*StopLossDistance, SymbolDigits);
   else if(OrderType == ORDER_TYPE_SELL)
      TakeProfitPrice = NormalizeDouble(EntryPrice - RiskReward*StopLossDistance, SymbolDigits);
   else
      TakeProfitPrice = 0.0;      
      
   //Print
   Print("Take Profit Price = ", TakeProfitPrice);
   
   //Return value
   return (TakeProfitPrice);
}

//+------------------------------------------------------------------+
//| Get Risk Amount from Account                                     |
//+------------------------------------------------------------------+
double GetRiskAmount(string RiskMethod,double RiskPercent, double StartingEquity) export
{
   double RiskAmount = 0.0;
   if(RiskMethod == "Fixed")
      RiskAmount = RiskPercent * StartingEquity;
   else if(RiskMethod == "Compounding")
      RiskAmount = RiskPercent * AccountInfoDouble(ACCOUNT_BALANCE);
   else
      RiskAmount =  0.0;
   
   //Print
   Print("Risk Amount = ", RiskAmount);
   
   //Return value
   return(RiskAmount);   
}


//+------------------------------------------------------------------+
//| Process trailing stop loss                                       |
//+------------------------------------------------------------------+
void ProcessTradeTsl(string CurrentSymbol, ulong Ticket, double NewStopLossPrice) export
{
   //Select current position by ticket. If no position is selected, return.
   if (!PositionSelectByTicket(Ticket))
      return;
   
   //Store position data variables
   ulong  Direction         = PositionGetInteger(POSITION_TYPE);
   double CurrentStopLoss   = PositionGetDouble(POSITION_SL);
   double CurrentTakeProfit = PositionGetDouble(POSITION_TP);   
   
   //Check if position direction is long and if new stop loss is greater than current stop loss
   if ((Direction==POSITION_TYPE_BUY) && (NewStopLossPrice > CurrentStopLoss))
   {    
      Trade.PositionModify(Ticket, NewStopLossPrice, CurrentTakeProfit);
      Print("Ticket ", Ticket, " for symbol ", CurrentSymbol," stop loss adjusted to ", NewStopLossPrice);
   } 

   //Check if position direction is long and if new stop loss is less than current stop loss
   if ((Direction==POSITION_TYPE_SELL) && (NewStopLossPrice < CurrentStopLoss))
   {    
      Trade.PositionModify(Ticket, NewStopLossPrice, CurrentTakeProfit);
      Print("Ticket ", Ticket, " for symbol ", CurrentSymbol," stop loss adjusted to ", NewStopLossPrice);
   } 
   
   //Return value
   return;
}

//+------------------------------------------------------------------+