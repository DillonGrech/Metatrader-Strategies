//+------------------------------------------------------------------+
//|                              Multi-Symbol-Indicator-Ea-v1.01.mq5 |
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
//|                                                    Patch Notes 1 |
//| Patch version 1 is a template file for those following along     |
//| in my youtube tutorial. Completed version will be released as    |
//| patch version 2.                                                 |
//|                                                                  |
//+------------------------------------------------------------------+
//|                                              Strategy Conditions |
//| Long & short trades, 1x EntryTrigger, 2x Filter, 1x Exit Trigger |
//| Fixed position size and no stop loss (exit on exit trigger)      |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Copyright 2024, Dillon Grech"
#property version   "1.01"

//+------------------------------------------------------------------+
//| Expert Setup                                                     |
//+------------------------------------------------------------------+
//Libraries

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
         
        
         //Enter Long Trades


         //Enter Short Trades
        
        
         //Exit Trades
         
         
         //Update Symbol Metrics
         SymbolMetrics[SymbolLoop] = CurrentSymbol + 
                                     " | Ticks Processed: " + IntegerToString(TicksProcessed[SymbolLoop]) +
                                     " | Last Candle: " + TimeToString(TimeLastTickProcessed[SymbolLoop]) +
                                     " | Open Ticket: " + IntegerToString(TicketNumber[SymbolLoop]) +
                                     " | Open Ticket Direction: " + PositionDirection
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

//Resize core and indicator arays for multi-symbol EA
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