//+------------------------------------------------------------------+
//|                                                      AlBrooksEMA |
//|                                      Copyright 2024, FinanceTech |
//|                                  maryamazhdari.mailbox@gmail.com |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot EMA
#property indicator_label1  "EMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_style1  STYLE_DASHDOT
#property indicator_width1  2
//#property indicator_color2 Red
//--- input parameters
input int                  ma_period = 20;                 // Period of Ma
input ENUM_TIMEFRAMES      TF = PERIOD_H1;                 // TimeFrame
input int                  ma_shift = 0;                   // Shift
input ENUM_MA_METHOD       ma_method = MODE_EMA;           // Method
input ENUM_APPLIED_PRICE   applied_price = PRICE_CLOSE;    // Apply to
//input ENUM_LINE_STYLE      InpStyle = STYLE_DASH;          // Line style
//input color               lineColor = clrGray;            // Line Color
//extern color color1 = Red;
//--- indicator buffers
double         EMABuffer[];

int EMAHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,EMABuffer,INDICATOR_DATA);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   
//   //Assign the color indexes array with indicator's buffer
//   SetIndexBuffer(1,buffer_color_line,INDICATOR_COLOR_INDEX);
//   //Specify colors for each index
//   PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,lineColor);   //Zeroth index -> Blue
//   
   ////Assign the color indexes array with indicator's buffer
   //SetIndexBuffer(1,buffer_style_line,INDICATOR_COLOR_INDEX);
   ////Specify colors for each index
   //PlotIndexSetInteger(0,PLOT_LINE_STYLE,0,STYLE_SOLID);   //Zeroth index -> Blue

//EMAHandle = iMA(NULL,TF,20,0,MODE_EMA,PRICE_CLOSE);
EMAHandle=iMA(NULL,TF,ma_period,ma_shift,ma_method,applied_price);
//EMAHandle=iCustom(NULL,TF,ma_period,ma_shift,ma_method,InpStyle,applied_price);
   //EMAHandle=iCustom(NULL,TF,"Custom MA",
   //                  ma_period,ma_shift,ma_method,clrGray,InpStyle,applied_price);
                     
   if(EMAHandle==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      return(INIT_FAILED);
     }
   else
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
   if(TF<Period())
      return (0);

   int TFMaxBars = iBars(NULL,TF);
   int EMACalculated = BarsCalculated(EMAHandle);
   if(EMACalculated<TFMaxBars)
      return (prev_calculated);
//---
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(EMABuffer,true);

   static datetime LT = 0;

   if(LT == 0 || LT < time[0])
     {
      int Limit = MathMin(TerminalInfoInteger(TERMINAL_MAXBARS),(rates_total-prev_calculated));
      int TFBar = 0;
      double TempEMABuffer[1];

      CopyBuffer(EMAHandle,0,TFBar,1,TempEMABuffer);

      for(int i=0; i<Limit; i++)
        {
         while(time[i]<iTime(NULL,TF,TFBar))
           {
            TFBar++;
            CopyBuffer(EMAHandle,0,TFBar,1,TempEMABuffer);
           }
         EMABuffer[i] = TempEMABuffer[0];
        }

      LT = time[0];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
