//+------------------------------------------------------------------+
//|                                            Range Breakout v2.mq5 |
//|                                                     yin zhanpeng |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "yin zhanpeng"
#property link      ""
#property version   "1.00"
#include <Trade/Trade.mqh>
CTrade trade;
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+

input double lot_size = 0.01;  // Lot size
input static int magic_num = 1002;  //Magic Number

enum sl_method
  {
   point_sl,  //Points System
   range_multi_sl  // Range Multiplier
  };
enum tp_method
  {
   point_tp, //Points System
   range_multi_tp, // Range Multiplier
   risk_multi_tp  // Risk Multiplier
  };
enum breakout_mode
  {
   mode_1,  //  5 candles
   mode_2   // candles 1-unli
  };
input bool close_at_condition = false;  // Close at the new set up
input bool reverse_trade = false;  // Reverse Trading
input bool break_even = false; // Break even mode
input sl_method sl_mode = point_sl; // SL mode
input tp_method tp_mode = point_tp;  // TP mode
input double stop_loss = 100; // SL
input double take_profit = 100;  //TP
input int be_after_pt = 100; // Breakeven after certain points
input int set_be = 20; // how many points in profit to be
input breakout_mode chose_modes = mode_1;  // Chose Mode
input int Bars_range = 15;  // number of consoludation candles

input int unli_range = 7;  // Mode 2 No of candles
//+------------------------------------------------------------------+
//| fib filter mode 2                                                |
//+------------------------------------------------------------------+

input bool fib_filter_mode2 = false; // Fib filter for mode 2
input bool zone_0382 = false;  // Range below 0.383 lvl
input bool zone_05 = false;  //Range below 0.5 lvl
input bool zone_0618 = false; // Range below 0.618 lvl

//+------------------------------------------------------------------+
//| time filter                                                      |
//+------------------------------------------------------------------+

input bool time_fil = false; // Time Filter
input string start_t_1 = "02:00"; // Start Trading time 1
input string end_t_1 = "24:00";  // End Trading time 1
input string start_t_2 = "02:00"; // Start Trading time 2
input string end_t_2 = "24:00";  // End Trading time 3
input string start_t_3 = "02:00"; // Start Trading time 3
input string end_t_3 = "24:00";  // End Trading time 3
//+------------------------------------------------------------------+
//| Global Variable                                                  |
//+------------------------------------------------------------------+
double sorted_high_1;
double sorted_high_2;
double sorted_high_3;
double sorted_high_4;
double sorted_high_5;
int sort_count;
double sorted_low_1;
double sorted_low_2;
double sorted_low_3;
double sorted_low_4;
double sorted_low_5;
// compare output values
double compare_out_high;
double compare_out_low;
// break out lvls
double breakout_high;
double breakout_low;
// condition variable
double condition_high;
double condition_low;
double sub_high;
// time
string current_time;
bool allow_trading = false;
int OnInit()
  {

   trade.SetExpertMagicNumber(magic_num);


   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

//+------------------------------------------------------------------+
//| time                                                             |
//+------------------------------------------------------------------+
   datetime time = TimeCurrent();
   current_time = TimeToString(time,TIME_MINUTES);
   check_trading_time();
   if(time_fil == false)
     {
      allow_trading = true;
     }
//+------------------------------------------------------------------+
//| Range                                                            |
//+------------------------------------------------------------------+

// highs and lows before the consoludations (mode 1 max 5 candles)
   double high_5 = iHigh(_Symbol,PERIOD_CURRENT,Bars_range + 5);
   double low_5 = iLow(_Symbol,PERIOD_CURRENT,Bars_range + 5);

   double high_4 = iHigh(_Symbol,PERIOD_CURRENT,Bars_range + 4);
   double low_4 = iLow(_Symbol,PERIOD_CURRENT,Bars_range + 4);

   double high_3 = iHigh(_Symbol,PERIOD_CURRENT,Bars_range + 3);
   double low_3 = iLow(_Symbol,PERIOD_CURRENT,Bars_range + 3);

   double high_2 = iHigh(_Symbol,PERIOD_CURRENT,Bars_range + 2);
   double low_2 = iLow(_Symbol,PERIOD_CURRENT,Bars_range + 2);

   double high_1 = iHigh(_Symbol,PERIOD_CURRENT,Bars_range + 1);
   double low_1 = iLow(_Symbol,PERIOD_CURRENT,Bars_range + 1);

// highs and lows before the consoludations (mode 2 unlimited candles)

   int unli_high_index = iHighest(_Symbol,PERIOD_CURRENT,MODE_HIGH,unli_range,1 + Bars_range);
   int unli_low_index = iLowest(_Symbol,PERIOD_CURRENT,MODE_LOW,unli_range,1 + Bars_range);

   double unli_high = iHigh(_Symbol,PERIOD_CURRENT,unli_high_index);
   double unli_low = iLow(_Symbol,PERIOD_CURRENT,unli_low_index);

// consolidation Finding the highest high and lowest low

   int consolidation_high_index = iHighest(_Symbol,PERIOD_CURRENT,MODE_HIGH,Bars_range,1);
   int consolidation_low_index = iLowest(_Symbol,PERIOD_CURRENT,MODE_LOW,Bars_range,1);

   double consolidation_high = iHigh(_Symbol,PERIOD_CURRENT,consolidation_high_index);
   double consolidation_low = iLow(_Symbol,PERIOD_CURRENT,consolidation_low_index);

// order counts and position count

   int order_count = 0;
   int position_count = 0;
// bid value
   double bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);

//+------------------------------------------------------------------+
//| Sorting the highs                                                |
//+------------------------------------------------------------------+
   sort(high_1,high_2,high_3,high_4,high_5);
   if(sort_count == 4)
     {
      sorted_high_1 =high_1;
     }
   if(sort_count == 3)
     {
      sorted_high_2 =high_1;
     }
   if(sort_count == 2)
     {
      sorted_high_3 =high_1;
     }
   if(sort_count == 1)
     {
      sorted_high_4 =high_1;
     }
   if(sort_count == 0)
     {
      sorted_high_5 =high_1;
     }


   sort(high_2,high_1,high_3,high_4,high_5);
   if(sort_count == 4)
     {
      sorted_high_1 =high_2;
     }
   if(sort_count == 3)
     {
      sorted_high_2 =high_2;
     }
   if(sort_count == 2)
     {
      sorted_high_3 =high_2;
     }
   if(sort_count == 1)
     {
      sorted_high_4 =high_2;
     }
   if(sort_count == 0)
     {
      sorted_high_5 =high_2;
     }


   sort(high_3,high_2,high_1,high_4,high_5);
   if(sort_count == 4)
     {
      sorted_high_1 =high_3;
     }
   if(sort_count == 3)
     {
      sorted_high_2 =high_3;
     }
   if(sort_count == 2)
     {
      sorted_high_3 =high_3;
     }
   if(sort_count == 1)
     {
      sorted_high_4 =high_3;
     }
   if(sort_count == 0)
     {
      sorted_high_5 =high_3;
     }


   sort(high_4,high_2,high_3,high_1,high_5);
   if(sort_count == 4)
     {
      sorted_high_1 =high_4;
     }
   if(sort_count == 3)
     {
      sorted_high_2 =high_4;
     }
   if(sort_count == 2)
     {
      sorted_high_3 =high_4;
     }
   if(sort_count == 1)
     {
      sorted_high_4 =high_4;
     }
   if(sort_count == 0)
     {
      sorted_high_5 =high_4;
     }


   sort(high_5,high_2,high_3,high_4,high_1);
   if(sort_count == 4)
     {
      sorted_high_1 =high_5;
     }
   if(sort_count == 3)
     {
      sorted_high_2 =high_5;
     }
   if(sort_count == 2)
     {
      sorted_high_3 =high_5;
     }
   if(sort_count == 1)
     {
      sorted_high_4 =high_5;
     }
   if(sort_count == 0)
     {
      sorted_high_5 =high_5;
     }

//+------------------------------------------------------------------+
//| Sorting the lows                                                 |
//+------------------------------------------------------------------+

   sort(low_1,low_2,low_3,low_4,low_5);
   if(sort_count == 4)
     {
      sorted_low_1 = low_1;
     }
   if(sort_count == 3)
     {
      sorted_low_2 = low_1;
     }
   if(sort_count == 2)
     {
      sorted_low_3 = low_1;
     }
   if(sort_count == 1)
     {
      sorted_low_4 = low_1;
     }
   if(sort_count == 0)
     {
      sorted_low_5 = low_1;
     }

   sort(low_2,low_1,low_3,low_4,low_5);
   if(sort_count == 4)
     {
      sorted_low_1 = low_2;
     }
   if(sort_count == 3)
     {
      sorted_low_2 = low_2;
     }
   if(sort_count == 2)
     {
      sorted_low_3 = low_2;
     }
   if(sort_count == 1)
     {
      sorted_low_4 = low_2;
     }
   if(sort_count == 0)
     {
      sorted_low_5 = low_2;
     }

   sort(low_3,low_2,low_1,low_4,low_5);
   if(sort_count == 4)
     {
      sorted_low_1 = low_3;
     }
   if(sort_count == 3)
     {
      sorted_low_2 = low_3;
     }
   if(sort_count == 2)
     {
      sorted_low_3 = low_3;
     }
   if(sort_count == 1)
     {
      sorted_low_4 = low_3;
     }
   if(sort_count == 0)
     {
      sorted_low_5 = low_3;
     }

   sort(low_4,low_2,low_3,low_1,low_5);
   if(sort_count == 4)
     {
      sorted_low_1 = low_4;
     }
   if(sort_count == 3)
     {
      sorted_low_2 = low_4;
     }
   if(sort_count == 2)
     {
      sorted_low_3 = low_4;
     }
   if(sort_count == 1)
     {
      sorted_low_4 = low_4;
     }
   if(sort_count == 0)
     {
      sorted_low_5 = low_4;
     }

   sort(low_5,low_2,low_3,low_4,low_1);
   if(sort_count == 4)
     {
      sorted_low_1 = low_5;
     }
   if(sort_count == 3)
     {
      sorted_low_2 = low_5;
     }
   if(sort_count == 2)
     {
      sorted_low_3 = low_5;
     }
   if(sort_count == 1)
     {
      sorted_low_4 = low_5;
     }
   if(sort_count == 0)
     {
      sorted_low_5 = low_5;
     }
//+------------------------------------------------------------------+
//| orders and positions                                             |
//+------------------------------------------------------------------+

   for(int i = OrdersTotal() -1; i >= 0; i--) // orders
     {

      ulong ticket = OrderGetTicket(i);
      if(OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == magic_num)
        {
         order_count ++;
        }

     }

   for(int i = PositionsTotal() -1; i >= 0; i--) //  positions
     {

      ulong ticket = PositionGetTicket(i);
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == magic_num)
        {
         position_count ++;
        }

     }
//+------------------------------------------------------------------+
//| cancel orders                                                    |
//+------------------------------------------------------------------+

   if(order_count == 1 || position_count > 1 || (condition_high > consolidation_high && condition_low < consolidation_low && sub_high != high_1))
     {
      cancel_order();
     }


//+------------------------------------------------------------------+
//| Logic mode 1                                                     |
//+------------------------------------------------------------------+

   if(chose_modes == mode_1)
     {

      compare_high(sorted_high_1,sorted_high_2,sorted_high_3,sorted_high_4,sorted_high_5,consolidation_high);
      breakout_high = compare_out_high;

      compare_low(sorted_low_5,sorted_low_4,sorted_low_3,sorted_low_2,sorted_low_1,consolidation_low);
      breakout_low = compare_out_low;

      condition_high = sorted_high_1;
      condition_low = sorted_low_5;

     }

//+------------------------------------------------------------------+
//| Logic mode 2                                                     |
//+------------------------------------------------------------------+
   if(chose_modes == mode_2)
     {

      if(fib_filter_mode2 == true)
        {
         double range_vale = unli_high - unli_low;
         if(zone_0382 == true)
           {
            breakout_high = unli_high - range_vale * 0.382;
            NormalizeDouble(condition_high,_Digits);
            breakout_low = unli_low;
           }
         if(zone_05 == true)
           {
            breakout_high = unli_high - range_vale * 0.5;
            NormalizeDouble(condition_high,_Digits);
            breakout_low = unli_low;
           }
         if(zone_0618 == true)
           {
            condition_high = unli_high - range_vale * 0.618;
            NormalizeDouble(condition_high,_Digits);
            condition_low = unli_low;
           }
         ObjectCreate(0,"mode 2 high",OBJ_HLINE,0,0,unli_high);
         ObjectCreate(0,"mode 2 low",OBJ_HLINE,0,0,unli_low);
         condition_high = breakout_high;
         condition_low = breakout_low;

        }
      if(fib_filter_mode2 == false)
        {
         condition_high = unli_high;
         condition_low = unli_low;
         breakout_high = unli_high;
         breakout_low = unli_low;
        }
     }
//+------------------------------------------------------------------+
//| close_at_condition                                               |
//+------------------------------------------------------------------+

   if(close_at_condition == true
      && sub_high != high_1
      && position_count > 0
      && condition_high > consolidation_high
      && condition_low < consolidation_low
      &&(bid > breakout_high || bid < breakout_low))
     {
      close_posistion();
     }
//+------------------------------------------------------------------+
//| combine logic     Trading logic             reverse trade        |
//+------------------------------------------------------------------+
   if(condition_high > consolidation_high && condition_low < consolidation_low
      && position_count < 1
      && order_count < 2
      && bid > breakout_low
      && bid < breakout_high
      && sub_high != high_1
      && allow_trading == true)
     {
      ObjectCreate(0,"condition_high",OBJ_HLINE,0,0,condition_high);
      ObjectCreate(0,"condition_low",OBJ_HLINE,0,0,condition_low);

      ObjectCreate(0,"breakout_high",OBJ_HLINE,0,0,breakout_high);
      ObjectCreate(0,"breakout_low",OBJ_HLINE,0,0,breakout_low);
      double buylimt_sl = 0;
      double buylimt_tp = 0;
      double selllimt_sl = 0;
      double selllimt_tp = 0;

      double buystop_sl = 0;
      double sellstop_sl = 0;
      double buystop_tp = 0;
      double sellstop_tp = 0;

      if(sl_mode == point_sl)
        {
         sellstop_sl = breakout_low + stop_loss * _Point;
         buystop_sl = breakout_high - stop_loss * _Point;
         selllimt_sl = breakout_high + stop_loss * _Point;
         buylimt_sl = breakout_low - stop_loss * _Point;
         NormalizeDouble(buystop_sl,_Digits);
         NormalizeDouble(sellstop_sl,_Digits);
         NormalizeDouble(buylimt_sl,_Digits);
         NormalizeDouble(selllimt_sl,_Digits);
        }
      if(sl_mode == range_multi_sl)
        {
         sellstop_sl = breakout_low + ((breakout_high - breakout_low) * stop_loss);
         buystop_sl = breakout_high - ((breakout_high - breakout_low) * stop_loss);
         selllimt_sl = breakout_high + ((breakout_high - breakout_low) * stop_loss);
         buylimt_sl = breakout_low - ((breakout_high - breakout_low) * stop_loss);
         NormalizeDouble(buystop_sl,_Digits);
         NormalizeDouble(sellstop_sl,_Digits);
         NormalizeDouble(buylimt_sl,_Digits);
         NormalizeDouble(selllimt_sl,_Digits);
        }
      if(tp_mode == point_tp)
        {
         sellstop_tp = breakout_low - take_profit * _Point;
         buystop_tp = breakout_high + take_profit * _Point;
         buylimt_tp = breakout_low + take_profit *_Point;
         selllimt_tp = breakout_high - take_profit * _Point;
         NormalizeDouble(buystop_tp,_Digits);
         NormalizeDouble(sellstop_tp,_Digits);
         NormalizeDouble(selllimt_tp,_Digits);
         NormalizeDouble(buylimt_tp,_Digits);
        }
      if(tp_mode == range_multi_tp)
        {
         sellstop_tp = breakout_low - ((breakout_high - breakout_low) * take_profit);
         buystop_tp = breakout_high + ((breakout_high - breakout_low) * take_profit);
         buylimt_tp = breakout_low + ((breakout_high - breakout_low) * take_profit);
         selllimt_tp = breakout_high - ((breakout_high - breakout_low) * take_profit);
         NormalizeDouble(buystop_tp,_Digits);
         NormalizeDouble(sellstop_tp,_Digits);
         NormalizeDouble(selllimt_tp,_Digits);
         NormalizeDouble(buylimt_tp,_Digits);
        }
      if(tp_mode == risk_multi_tp)
        {
         sellstop_tp = breakout_low - ((sellstop_sl - breakout_low)*take_profit);
         buystop_tp = breakout_high + ((breakout_high - buystop_sl)*take_profit);
         buylimt_tp = breakout_low + ((breakout_low -buylimt_sl)*take_profit);
         selllimt_tp = breakout_high - ((selllimt_sl - breakout_high)*take_profit);
         NormalizeDouble(buystop_tp,_Digits);
         NormalizeDouble(sellstop_tp,_Digits);
         NormalizeDouble(selllimt_tp,_Digits);
         NormalizeDouble(buylimt_tp,_Digits);

        }

      //+------------------------------------------------------------------+
      //| close at condition                                               |
      //+------------------------------------------------------------------+
      if(close_at_condition == true)
        {

         buylimt_tp = 0;

         selllimt_tp = 0;

         buystop_tp = 0;

         sellstop_tp = 0;
        }

      if(reverse_trade == false)
        {


         trade.SellStop(lot_size,breakout_low,_Symbol,sellstop_sl,sellstop_tp);
         trade.BuyStop(lot_size,breakout_high,_Symbol,buystop_sl,buystop_tp);
         sub_high = high_1;
        }
      if(reverse_trade == true)
        {

         trade.BuyLimit(lot_size,breakout_low,_Symbol,buylimt_sl,buylimt_tp);
         trade.SellLimit(lot_size,breakout_high,_Symbol,selllimt_sl,selllimt_tp);
         sub_high = high_1;
        }

     }
//+------------------------------------------------------------------+
//| comments                                                         |
//+------------------------------------------------------------------+

   if(break_even == true)
     {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
         ulong ticket = PositionGetTicket(i);

         if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == magic_num)
           {
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
              {
               double sl = NormalizeDouble(PositionGetDouble(POSITION_SL),_Digits);
               double open = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN),_Digits);
               double current_price = NormalizeDouble(PositionGetDouble(POSITION_PRICE_CURRENT),_Digits);
               double open_with_point = NormalizeDouble((open + be_after_pt * _Point),_Digits);

               if(current_price > open_with_point && sl < open)
                 {

                  trade.PositionModify(ticket,open + set_be *_Point,PositionGetDouble(POSITION_TP));

                 }
              }
            if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
              {
               double sl = NormalizeDouble(PositionGetDouble(POSITION_SL),_Digits);
               double open = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN),_Digits);
               double current_price = NormalizeDouble(PositionGetDouble(POSITION_PRICE_CURRENT),_Digits);
               double open_with_point = NormalizeDouble((open - be_after_pt * _Point),_Digits);

               if(current_price < open_with_point && sl > open)
                 {

                  trade.PositionModify(ticket,open - set_be*_Point,PositionGetDouble(POSITION_TP));

                 }
              }

           }
        }
     }

//+------------------------------------------------------------------+
//| comments                                                         |
//+------------------------------------------------------------------+
   Comment(
      "\n\nSorted Highs:  ",sorted_high_1," ",sorted_high_2," ",sorted_high_3," ",sorted_high_4," ",sorted_high_5," "
      "\n\nHighs ",high_1," ",high_2," ",high_3," ",high_4," ",high_5,
      "\n\nSorted Lows:  ",sorted_low_1," ",sorted_low_2," ",sorted_low_3," ",sorted_low_4," ",sorted_low_5," "
      "\n\nLowss ",low_1," ",low_2," ",low_3," ",low_4," ",low_5,
      "\n\nBreakout Values  ", breakout_high, "  ", breakout_low,
      "\n\nCondition values  ", condition_high,"  ",condition_low,
      "\n\n orders and positions ", order_count,"  ",position_count, "  ", (breakout_high - breakout_low)
   );

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| sorting functions                                                |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void sort(double main, double sub1, double sub2, double sub3, double sub4)
  {
   int count = 0;
   if(main > sub1)
     {
      count ++;
     }
   if(main > sub2)
     {
      count ++;
     }
   if(main > sub3)
     {
      count ++;
     }
   if(main > sub4)
     {
      count ++;
     }
   sort_count = count;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void compare_high(double big1, double big2, double big3, double big4, double big5, double constant)
  {
   if(big1 > constant)
     {
      compare_out_high = big1;
     }
   if(big2 > constant)
     {
      compare_out_high = big2;
     }
   if(big3 > constant)
     {
      compare_out_high = big3;
     }
   if(big4 > constant)
     {
      compare_out_high = big4;
     }
   if(big5 > constant)
     {
      compare_out_high = big5;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void compare_low(double big1, double big2, double big3, double big4, double big5, double constant)
  {
   if(big1 < constant)
     {
      compare_out_low = big1;
     }
   if(big2 < constant)
     {
      compare_out_low = big2;
     }
   if(big3 < constant)
     {
      compare_out_low = big3;
     }
   if(big4 < constant)
     {
      compare_out_low = big4;
     }
   if(big5 < constant)
     {
      compare_out_low = big5;
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                  cancel orders                                   |
//+------------------------------------------------------------------+
void cancel_order()
  {
   for(int i = OrdersTotal()-1; i>=0; i--)
     {
      ulong orderticket = OrderGetTicket(i);
      if(OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == magic_num)
        {
         trade.OrderDelete(orderticket);

        }
     }

  }

//+------------------------------------------------------------------+
//|                     close posistion                              |
//+------------------------------------------------------------------+
void close_posistion()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--) // close posistion
     {

      ulong ticket = PositionGetTicket(i);
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == magic_num)
        {
         trade.PositionClose(ticket);
        }

     }
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|     check trading time                                           |
//+------------------------------------------------------------------+
bool check_trading_time()   // check trading time
  {

   if(StringSubstr(current_time,0,-1) == start_t_1 || StringSubstr(current_time,0,-1) == start_t_2 || StringSubstr(current_time,0,-1) == start_t_3)
     {
      allow_trading = true;
     }
   if(StringSubstr(current_time,0,-1) == end_t_1 || StringSubstr(current_time,0,-1) == end_t_2  || StringSubstr(current_time,0,-1) == end_t_3)
     {
      allow_trading = false;
     }
   return allow_trading;
  }
//+------------------------------------------------------------------+
