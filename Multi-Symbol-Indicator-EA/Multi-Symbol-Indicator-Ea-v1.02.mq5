//+------------------------------------------------------------------+
//|                              Multi-Symbol-Indicator-Ea-v1.02.mq5 |
//|                                     Copyright 2024, Dillon Grech |
//|                   YouTube: https://www.youtube.com/c/DillonGrech |
//|                           GitHub: https://github.com/DillonGrech |
//|                           Discord: https://discord.gg/xs3KpdUjSu |
//+------------------------------------------------------------------+
//|                                                  Version Notes 1 |
//| This file uses multi-symbol functionality. This EA incorporates  |
//| trigger and filter indicators to find the best combination of    |
//| indicators. Indicator signals are taked from Indicator Library.  |
//|                                                                  |
//+------------------------------------------------------------------+
//|                                                    Patch Notes 2 |
//| Completed version for the youtube tutorial.                      |
//|                                                                  |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
//|                                              Strategy Conditions |
//| Long & short trades, 1x EntryTrigger, 2x Filter, 1x Exit Trigger |
//| Fixed position size and no stop loss (exit on exit trigger)      |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Copyright 2024, Dillon Grech"
#property version   "1.02"

//+------------------------------------------------------------------+
//| Expert Setup                                                     |
//+------------------------------------------------------------------+
//Libraries
#import "IndicatorLibrary.ex5"
   int    GetIndicatorHandle(string Indicator, string CurrentSymbol, ENUM_TIMEFRAMES CurrentPeriod);
   string GetIndicatorTrigger(string Indicator, int IndicatorHandle, string CurrentSymbol, ENUM_TIMEFRAMES CurrentPeriod);
   string GetIndicatorFilter(string Indicator, int IndicatorHandle, string CurrentSymbol, ENUM_TIMEFRAMES CurrentPeriod);
   double GetIndicatorValue(int IndicatorHandle, int BufferValue);
#import

//Include
#include  <Trade\Trade.mqh> //Include MQL trade object functions
CTrade    *Trade;           //Declaire Trade as pointer to CTrade class

//Select expert magic number
input int MagicNumber = 1;  //Unique Identifier

//Multi-Symbol EA Variables - User can specify "Current" within input to trade current symbol only
input string AllTradableSymbols = "AUDJPY|CHFJPY|EURJPY|GBPJPY|USDJPY|AUDCHF|CADCHF|EURCHF|GBPCHF|USDCHF|AUDCAD|USDCAD|AUDUSD|EURUSD|GBPUSD|NZDUSD|AUDNZD|EURGBP";
int    NumberOfTradeableSymbols;
string SymbolArray[];

//Expert Core Arrays
string          SymbolMetrics[];
ulong           TicksProcessed[];
static datetime TimeLastTickProcessed[];
ulong           TicketNumber[];

//Expert Variables
string ExpertComments = "";
int    TicksReceived  =  0;

//Risk Metrics
input double LotSize = 0.1;

//+------------------------------------------------------------------+
//| Indicator Setup                                                  |
//+------------------------------------------------------------------+
//Indicator Entry 1 Variables - Entry Trigger
input string IndicatorE1 = "Macd_A_12_26_9";
      string IndicatorSignalE1;
      int    IndicatorHandleE1[];

//Indicator Filter 1 Variables
input string IndicatorF1 = "Ema_A_200";
      string IndicatorSignalF1;
      int    IndicatorHandleF1[];

//Indicator Filter 2 Variables
input string IndicatorF2 = "Na";
      string IndicatorSignalF2;
      int    IndicatorHandleF2[];

//Indicator Exit 1 Variables - Exit Trigger
      string IndicatorX1 = IndicatorF1;
      string IndicatorSignalX1;
      int    IndicatorHandleX1[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //Initiate C Trade
   InitiateTrade(MagicNumber);
   
   //Set up multi-symbol EA Tradable Symbols
   InitMultiSymbol();

   //Resize Arrays for Multi-Symbol EA
   ResizeCoreArrays();   
   
   //Resize Indicator Arrays for Multi-Symbol EA
   ResizeIndicatorArrays();

   //Initiate indicator handles for multi-symbol
   if(!InitIndicatorHanldes())
       return(INIT_FAILED);
      
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //Release Indicator Arrays
   ReleaseIndicatorHandles();
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   //Declare comment variables
   ExpertComments="";
   TicksReceived++;
  
   //Run multi-symbol loop   
   for(int SymbolLoop=0; SymbolLoop < NumberOfTradeableSymbols; SymbolLoop++)
   {
      //Store symbol vairables
      string CurrentSymbol = SymbolArray[SymbolLoop]; //Get current symbol

      
      //Check for new candle based of opening time of bar 
      if(TimeLastTickProcessed[SymbolLoop] != iTime(CurrentSymbol,Period(),0))
      {
         //Add to tick processed counter and store last tick processed for symbol
         TicksProcessed[SymbolLoop]++; 
         TimeLastTickProcessed[SymbolLoop]  = iTime(CurrentSymbol,Period(),0);      
         
         //Get any open position directions, reset on each run
         string PositionDirection = "NA";                  
         if(PositionSelectByTicket(TicketNumber[SymbolLoop]) == true)
         {
            if (PositionGetInteger(POSITION_TYPE) == 0)
               PositionDirection = "Long";
            else if (PositionGetInteger(POSITION_TYPE) == 1)
               PositionDirection = "Short";
         }
         else
            PositionDirection = "NA";
           
         //Get Indicator Signals
         IndicatorSignalE1 = GetIndicatorTrigger(IndicatorE1, IndicatorHandleE1[SymbolLoop], CurrentSymbol, Period());
         IndicatorSignalF1 = GetIndicatorFilter(IndicatorF1,  IndicatorHandleF1[SymbolLoop], CurrentSymbol, Period());
         IndicatorSignalF2 = GetIndicatorFilter(IndicatorF2,  IndicatorHandleF2[SymbolLoop], CurrentSymbol, Period());
         IndicatorSignalX1 = GetIndicatorTrigger(IndicatorX1, IndicatorHandleX1[SymbolLoop], CurrentSymbol, Period());
                     
         //Enter Long Trades
         if(
            (PositionDirection == "Short" || PositionDirection == "NA") && //enter if no current trades or short trades
            (IndicatorSignalE1 == "Long"                              ) && //enter on long trigger
            (IndicatorSignalF1 == "Long"  || IndicatorSignalF1 == "NA") && //enter on long filter or no filter indicator is selected
            (IndicatorSignalF2 == "Long"  || IndicatorSignalF2 == "NA")    //enter on long filter or no filter indicator is selected
         )
         {
            TicketNumber[SymbolLoop] = ProcessTradeOpen(CurrentSymbol, ORDER_TYPE_BUY, MagicNumber, LotSize); //Open positions and store ticket
            PositionDirection        = "Long";                                                                //Store position direction
         }        
         //Enter Short Trades
         else if(
            (PositionDirection == "Long"  || PositionDirection == "NA") && //enter if no current trades or short trades
            (IndicatorSignalE1 == "Short"                             ) && //enter on short trigger
            (IndicatorSignalF1 == "Short" || IndicatorSignalF1 == "NA") && //enter on short filter or no filter indicator is selected
            (IndicatorSignalF2 == "Short" || IndicatorSignalF2 == "NA")    //enter on short filter or no filter indicator is selected
         )
         {
            TicketNumber[SymbolLoop] = ProcessTradeOpen(CurrentSymbol, ORDER_TYPE_SELL, MagicNumber, LotSize); //Open positions and store ticket
            PositionDirection        = "Short";                                                                //Store position direction
         }     
         //Exit Trades  
         else if(
            (PositionDirection == "Long"  && IndicatorSignalX1 == "Short") || //exit long trades on exit indicator short signal
            (PositionDirection == "Short" && IndicatorSignalX1 == "Long")     //exit short trades on exit indicator long signal
         )
         {   
            ProcessTradeClose(CurrentSymbol,TicketNumber[SymbolLoop]);
         }                          
         //Update Symbol Metrics
         SymbolMetrics[SymbolLoop] = CurrentSymbol + 
                                     " | Ticks Processed: " + IntegerToString(TicksProcessed[SymbolLoop]) +
                                     " | Last Candle: " + TimeToString(TimeLastTickProcessed[SymbolLoop]) +
                                     " | Open Ticket: " + IntegerToString(TicketNumber[SymbolLoop]) +
                                     " | Open Ticket Direction: " + PositionDirection +
                                     " | Entry 1 (" + IntegerToString(IndicatorHandleE1[SymbolLoop])+") : " + IndicatorSignalE1 +
                                     " | Filter 1 (" + IntegerToString(IndicatorHandleF1[SymbolLoop])+") : " + IndicatorSignalF1 +
                                     " | Filter 2 (" + IntegerToString(IndicatorHandleF2[SymbolLoop])+") : " + IndicatorSignalF2 +
                                     " | Exit 1 (" + IntegerToString(IndicatorHandleX1[SymbolLoop])+") : " + IndicatorSignalX1                     
                                     ;
      }
      
      //Update expert comments for each symbol
      ExpertComments = ExpertComments + SymbolMetrics[SymbolLoop] + "\n\r";
   }
   //Comment expert behaviour
   Comment("\n\rExpert: ", MagicNumber, "\n\r",
            "MT5 Server Time: ", TimeCurrent(), "\n\r",
            "Ticks Received: ", TicksReceived,"\n\r\n\r",  
            "Symbols Traded:\n\r", 
            ExpertComments
            );
}

//+------------------------------------------------------------------+
//| Multi-Symbol Custom Functions                                    |
//+------------------------------------------------------------------+
//Initiate MultiSymbol Function
void InitMultiSymbol() 
{
   //Set up symbol arrays
   //If current symbol, select symbol from EA settings
   if(AllTradableSymbols == "Current")
   {
      NumberOfTradeableSymbols = 1;
      ArrayResize(SymbolArray,NumberOfTradeableSymbols);
      SymbolArray[0] = Symbol();
      Print("EA will process ", NumberOfTradeableSymbols, " Symbol: ", SymbolArray[0]);
   } 
   //Else test all symbols
   else
   {
      NumberOfTradeableSymbols = StringSplit(AllTradableSymbols, '|', SymbolArray);
      ArrayResize(SymbolArray,NumberOfTradeableSymbols);
      Print("EA will process ", NumberOfTradeableSymbols, " Symbols: ", AllTradableSymbols);
   }
}

//Resize core arrays for multi-symbol EA
void ResizeCoreArrays()
{
   //Resize core arrays for Multi-Symbol EA
   ArrayResize(SymbolMetrics,         NumberOfTradeableSymbols);
   ArrayResize(TicksProcessed,        NumberOfTradeableSymbols); 
   ArrayResize(TimeLastTickProcessed, NumberOfTradeableSymbols);
   ArrayResize(TicketNumber,          NumberOfTradeableSymbols);
}
//+------------------------------------------------------------------+
//| Indicator library custom functions                               |
//+------------------------------------------------------------------+
//Resize indicator arrays for Multi-Symbol EA
void ResizeIndicatorArrays()
{
   ArrayResize(IndicatorHandleE1, NumberOfTradeableSymbols);
   ArrayResize(IndicatorHandleF1, NumberOfTradeableSymbols);
   ArrayResize(IndicatorHandleF2, NumberOfTradeableSymbols);
   ArrayResize(IndicatorHandleX1, NumberOfTradeableSymbols);
}

//Release indicator handles from Metatrader cache for multi-symbol EA
void ReleaseIndicatorHandles()
{
   for(int SymbolLoop=0; SymbolLoop < NumberOfTradeableSymbols; SymbolLoop++)
   {
      IndicatorRelease(IndicatorHandleE1[SymbolLoop]);
      IndicatorRelease(IndicatorHandleF1[SymbolLoop]);
      IndicatorRelease(IndicatorHandleF2[SymbolLoop]);
      IndicatorRelease(IndicatorHandleX1[SymbolLoop]);
   }
   Print("Handle released for all symbols");   
}

//Set up Indicator1 Handle for Multi-Symbol EA
bool InitIndicatorHanldes()
{
   for(int SymbolLoop=0; SymbolLoop < NumberOfTradeableSymbols; SymbolLoop++)
   {
      IndicatorHandleE1[SymbolLoop] = GetIndicatorHandle(IndicatorE1, SymbolArray[SymbolLoop],Period());
      IndicatorHandleF1[SymbolLoop] = GetIndicatorHandle(IndicatorF1, SymbolArray[SymbolLoop],Period());
      IndicatorHandleF2[SymbolLoop] = GetIndicatorHandle(IndicatorF2, SymbolArray[SymbolLoop],Period());
      IndicatorHandleX1[SymbolLoop] = GetIndicatorHandle(IndicatorX1, SymbolArray[SymbolLoop],Period());
   }
   return true;     
}

//+------------------------------------------------------------------+
//| Process trades custom functions                                  |
//+------------------------------------------------------------------+
//Initiate cTrade and magic number
void InitiateTrade(int ID)
{   
   Trade = new CTrade();
   Trade.SetExpertMagicNumber(ID);
   return;  
}

//Process trades function - Fixed Lot Position Size, No SL/TP
ulong ProcessTradeOpen(string CurrentSymbol, ENUM_ORDER_TYPE OrderType, int ID, double Risk) export
{
   //Set symbol string and variables 
   int    SymbolDigits    = (int) SymbolInfoInteger(CurrentSymbol,SYMBOL_DIGITS); //note - typecast required to remove error
   double Price           = 0.0;
   double StopLossPrice   = 0.0;
   double TakeProfitPrice = 0.0;
   
   //Open buy or sell orders
   if(OrderType == ORDER_TYPE_BUY)
   {
      Price = NormalizeDouble(SymbolInfoDouble(CurrentSymbol, SYMBOL_ASK), SymbolDigits);
   } 
   else if(OrderType == ORDER_TYPE_SELL)
   {
      Price = NormalizeDouble(SymbolInfoDouble(CurrentSymbol, SYMBOL_BID), SymbolDigits);
   }
        
   //Close any current positions and open new position
   Trade.PositionClose(CurrentSymbol);
   Trade.SetExpertMagicNumber(ID);  
   Trade.PositionOpen(CurrentSymbol,OrderType,Risk,Price,StopLossPrice,TakeProfitPrice,__FILE__);
   
   
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
   Print("Trade Processed For Ticket ", Ticket, " Symbol ", CurrentSymbol," OrderType ",OrderType, " Lot Size ", LotSize);
   
   return(Ticket);
}

//Process trades close
void   ProcessTradeClose(string CurrentSymbol, ulong Ticket) export
{
   Trade.PositionClose(Ticket);
   
   //Print successful
   Print("Trade Closed For Ticket ", Ticket, " Symbol ", CurrentSymbol);
}
//+------------------------------------------------------------------+