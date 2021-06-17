/*
Copyright (C) 2021 Mateus Matucuma Teixeira

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/
#ifndef MINICHARTS_H
#define MINICHARTS_H
//+------------------------------------------------------------------+
//|                         Stats on Amplitude, Spread and Clock.mq5 |
//|                         Copyright 2021, Mateus Matucuma Teixeira |
//|                                            mateusmtoss@gmail.com |
//| GNU General Public License version 2 - GPL-2.0                   |
//| https://opensource.org/licenses/gpl-2.0.php                      |
//+------------------------------------------------------------------+
// https://github.com/BRMateus2/MiniCharts-Indicator/
//---- Main Properties
#property copyright "2021, Mateus Matucuma Teixeira"
#property link "https://github.com/BRMateus2/"
#property description "This Indicator will create Mini Charts on the Chart Window, it also supports a Sub Window if you place it inside a Sub Window.\n"
#property description "Be aware that it is normal for the Mini Charts to have a delay, it is made so the object creation tries to be on the foreground of the chart."
#property version "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0
//---- Definitions
#define ErrorPrint(Dp_error) Print("ERROR: " + Dp_error + " at \"" + __FUNCTION__ + ":" + IntegerToString(__LINE__) + "\", last internal error: " + IntegerToString(GetLastError()) + " (" + __FILE__ + ")"); ResetLastError(); DebugBreak(); // It should be noted that the GetLastError() function doesn't zero the _LastError variable. Usually the ResetLastError() function is called before calling a function, after which an error appearance is checked.
//#define INPUT const
#ifndef INPUT
#define INPUT input
#endif
//---- Indicator Definitions
const string iName = "Mini Charts";
enum Corner {
    kCornerLeft, // Left Corner of Chart
    kCornerRight // Right Corner of Chart
};
//---- Input Parameters
//---- "Mini Chart Settings"
input group "Mini Chart Settings"
INPUT ENUM_TIMEFRAMES c0PeriodInp = PERIOD_D1; // Mini Chart 0 Period (current = disabled)
INPUT ENUM_TIMEFRAMES c1PeriodInp = PERIOD_M1; // Mini Chart 1 Period (current = disabled)
INPUT ENUM_TIMEFRAMES c2PeriodInp = PERIOD_CURRENT; // Mini Chart 2 Period (current = disabled)
INPUT ENUM_TIMEFRAMES c3PeriodInp = PERIOD_CURRENT; // Mini Chart 3 Period (current = disabled)
INPUT Corner cCorner = kCornerLeft; // Mini Chart Corner
INPUT int cOffsetX = 0; // X Distance or Horizontal Position Offset
INPUT int cOffsetY = 20; // Y Distance or Vertical Position Offset
INPUT int cOffsetYBottom = 20; // Y Space on the Bottom
INPUT int cSizeX = 270; // X (Horizontal) Size in Pixels
INPUT int cSpacingY = 0; // Vertical gap between objects
INPUT bool cShowDate = true; // Show date in Mini Charts
INPUT bool cShowPrice = true; // Show price in Mini Charts
INPUT int cScale = 2; // Mini Chart Scale
INPUT int cDelay = 3; // Creation delay in s (so indicators don't foreground)
datetime now = 0; // Defined at OnInit()
bool cCreated = false; // Mini Charts are created
const color cColorSelected = clrRed; // Mini Chart color when highlighted (selected)
const ENUM_LINE_STYLE cStyleSelected = STYLE_SOLID; // Mini Chart color when highlighted (selected)
const int cPointSize = 1; // Move Point Size
const bool cBackground = false; // Mini Charts are printed in the background
const bool cSelectable = false; // Mini Charts are selectable
const bool cHidden = true; // Mini Charts are hidden in the Object List
const int cZOrder = 0; // Mini Chart Z Order for mouse click
int chartSizeY = 0; // Size of the Chart Y Axis
int cCount = 0; // Valid Mini Charts counter
//---- Objects
const string c0Obj = "MT_Chart0"; // Object Chart 0, used for naming
const string c1Obj = "MT_Chart1"; // Object Chart 1, used for naming
const string c2Obj = "MT_Chart2"; // Object Chart 2, used for naming
const string c3Obj = "MT_Chart3"; // Object Chart 3, used for naming
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// Constructor or initialization function
// https://www.mql5.com/en/docs/basis/function/events
// https://www.mql5.com/en/articles/100
//+------------------------------------------------------------------+
int OnInit()
{
    now = TimeLocal();
    IndicatorSetString(INDICATOR_SHORTNAME, iName);
    ObjectDelete(ChartID(), c0Obj);
    ObjectDelete(ChartID(), c1Obj);
    ObjectDelete(ChartID(), c2Obj);
    ObjectDelete(ChartID(), c3Obj);
// Count the number of valid Mini Charts
    if(c0PeriodInp != PERIOD_CURRENT) {
        cCount = cCount + 1;
    }
    if(c1PeriodInp != PERIOD_CURRENT) {
        cCount = cCount + 1;
    }
    if(c2PeriodInp != PERIOD_CURRENT) {
        cCount = cCount + 1;
    }
    if(c3PeriodInp != PERIOD_CURRENT) {
        cCount = cCount + 1;
    }
    if(cCount == 0) {
        ErrorPrint("All Mini Charts are set to PERIOD_CURRENT, there is nothing to show then, because they are all disabled");
        return INIT_PARAMETERS_INCORRECT;
    }
// Get Chart Attributes
    long chartSizeYTemp;
    if(!ChartGetInteger(ChartID(), CHART_HEIGHT_IN_PIXELS, ChartWindowFind(ChartID(), iName), chartSizeYTemp)) {
        ErrorPrint("ChartGetInteger(ChartID(), CHART_HEIGHT_IN_PIXELS, ChartWindowFind(ChartID(), iName), chartSizeY)");
        return INIT_FAILED;
    }
    chartSizeY = (int) chartSizeYTemp;
    if(!EventSetTimer(1)) {
        ErrorPrint("!EventSetTimer(1)");
    }
    return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
// Destructor or Deinitialization function
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    ObjectDelete(ChartID(), c0Obj);
    ObjectDelete(ChartID(), c1Obj);
    ObjectDelete(ChartID(), c2Obj);
    ObjectDelete(ChartID(), c3Obj);
    return;
}
//+------------------------------------------------------------------+
// Timer function
//+------------------------------------------------------------------+
void OnTimer()
{
// Indicator Sleep() is not allowed, so we are trying to create the chart objects only after all chart indicator data are calculated, to account for the issue of other indicators foregrounding the priority objects
// This is a unfortunate performance cost, to try to enforce those objects as foreground (not guaranteed)
// Issue https://www.mql5.com/en/forum/133175
// Issue https://www.mql5.com/en/forum/133995
// Issue https://www.mql5.com/en/forum/363531
    if(cCreated == false && now < TimeLocal() - cDelay) {
        cCreated = true;
// Create Objects
        long thisY = cOffsetY; // Represents a Y axis position at printing (imagine a pointing arrow at the end of Y axis of the last object created)
        long thisYIncrement = (long) MathRound(((double) chartSizeY / (double) cCount) - ((double) cOffsetYBottom / (double) cCount) - ((double) cOffsetY / (double) cCount)); // Increment the "pointing" for every object created, rounded for precision
        long thisXOffset = (cCorner == kCornerLeft ? cOffsetX : cOffsetX + cSizeX); // MQL5 X axis offset on the left corner works by adding the object position, while on the right corner works by subtracting the object position (The Cartesian Coordinates system with rotation)
        if(c0PeriodInp != PERIOD_CURRENT) {
            ObjectChartCreate(Symbol(), ChartID(), ChartWindowFind(ChartID(), iName), c0Obj, c0PeriodInp,
                              thisXOffset,
                              thisY,
                              cSizeX,
                              thisYIncrement,
                              EnumToEnumBaseCorner(cCorner), cScale, cShowDate, cShowPrice, cColorSelected, cStyleSelected, cPointSize, cBackground, cSelectable, cHidden, cZOrder
                             );
            thisY = thisY + thisYIncrement;
        }
        if(c1PeriodInp != PERIOD_CURRENT) {
            ObjectChartCreate(Symbol(), ChartID(), ChartWindowFind(ChartID(), iName), c1Obj, c1PeriodInp,
                              thisXOffset,
                              thisY,
                              cSizeX,
                              thisYIncrement,
                              EnumToEnumBaseCorner(cCorner), cScale, cShowDate, cShowPrice, cColorSelected, cStyleSelected, cPointSize, cBackground, cSelectable, cHidden, cZOrder
                             );
            thisY = thisY + thisYIncrement;
        }
        if(c2PeriodInp != PERIOD_CURRENT) {
            ObjectChartCreate(Symbol(), ChartID(), ChartWindowFind(ChartID(), iName), c2Obj, c2PeriodInp,
                              thisXOffset,
                              thisY,
                              cSizeX,
                              thisYIncrement,
                              EnumToEnumBaseCorner(cCorner), cScale, cShowDate, cShowPrice, cColorSelected, cStyleSelected, cPointSize, cBackground, cSelectable, cHidden, cZOrder
                             );
            thisY = thisY + thisYIncrement;
        }
        if(c3PeriodInp != PERIOD_CURRENT) {
            ObjectChartCreate(Symbol(), ChartID(), ChartWindowFind(ChartID(), iName), c3Obj, c3PeriodInp,
                              thisXOffset,
                              thisY,
                              cSizeX,
                              thisYIncrement,
                              EnumToEnumBaseCorner(cCorner), cScale, cShowDate, cShowPrice, cColorSelected, cStyleSelected, cPointSize, cBackground, cSelectable, cHidden, cZOrder
                             );
        }
        ChartRedraw(ChartID());
    }
    return;
}
//+------------------------------------------------------------------+
// Calculation function
//+------------------------------------------------------------------+
int OnCalculate(
    const int rates_total, // price[] array size
    const int prev_calculated, // number of handled bars at the previous call
    const int begin, // index number in the price[] array meaningful data starts from
    const double& price[]) // array of values for calculation
{
    return rates_total; // There are no calculations to be executed
}
//+------------------------------------------------------------------+
// Extra functions, utilities and conversion
//+------------------------------------------------------------------+
ENUM_BASE_CORNER EnumToEnumBaseCorner(Corner e)
{
    if(e == kCornerLeft) return CORNER_LEFT_UPPER;
    else if(e == kCornerRight) return CORNER_RIGHT_UPPER;
    else {
        ErrorPrint("undefined");
        return CORNER_LEFT_UPPER;
    }
}
//+------------------------------------------------------------------+
//| Creating Chart object
//+------------------------------------------------------------------+
bool ObjectChartCreate(const string            symbol = "EURUSD",          // symbol
                       const long              chart_ID = 0,               // chart's ID
                       const int               sub_window = 0,             // subwindow index
                       const string            name = "Chart",             // object name
                       const ENUM_TIMEFRAMES   period = PERIOD_H1,         // period
                       const long              x = 0,                      // X coordinate
                       const long              y = 0,                      // Y coordinate
                       const long              width = 300,                // width
                       const long              height = 200,               // height
                       const ENUM_BASE_CORNER  corner = CORNER_LEFT_UPPER, // anchoring corner
                       const long              scale = 2,                  // scale
                       const bool              date_scale = true,          // time scale display
                       const bool              price_scale = true,         // price scale display
                       const color             clr = clrRed,               // border color when highlighted
                       const ENUM_LINE_STYLE   style = STYLE_SOLID,        // line style when highlighted
                       const long              point_width = 1,            // move point size
                       const bool              back = false,               // in the background
                       const bool              selection = false,          // highlight to move
                       const bool              hidden = true,              // hidden in the object list
                       const long              z_order = 0)                // priority for mouse click
{
//--- reset the error value
    ResetLastError();
//--- create Chart object
    if(!ObjectCreate(chart_ID, name, OBJ_CHART, sub_window, 0, 0)) {
        Print(__FUNCTION__,
              ": failed to create \"Chart\" object! Error code = ", GetLastError());
        return false;
    }
//--- set object coordinates
    ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
//--- set object size
    ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
    ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
//--- set the chart's corner, relative to which point coordinates are defined
    ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner);
//--- set the symbol
    ObjectSetString(chart_ID, name, OBJPROP_SYMBOL, symbol);
//--- set the period
    ObjectSetInteger(chart_ID, name, OBJPROP_PERIOD, period);
//--- set the scale
    ObjectSetInteger(chart_ID, name, OBJPROP_CHART_SCALE, scale);
//--- display (true) or hide (false) the time scale
    ObjectSetInteger(chart_ID, name, OBJPROP_DATE_SCALE, date_scale);
//--- display (true) or hide (false) the price scale
    ObjectSetInteger(chart_ID, name, OBJPROP_PRICE_SCALE, price_scale);
//--- set the border color when object highlighting mode is enabled
    ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- set the border line style when object highlighting mode is enabled
    ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
//--- set a size of the anchor point for moving an object
    ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, point_width);
//--- display in the foreground (false) or background (true)
    ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- hide (true) or display (false) graphical object name in the object list
    ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
    ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
    return true;
}
//+------------------------------------------------------------------+
//| Header Guard #endif
//+------------------------------------------------------------------+
#endif
//+------------------------------------------------------------------+
