module Chart ( attachOn
             , line
             , bar
             , radar
             , polarArea
             , pie
             , doughnut
             , update
             , addDataType1
             , addDataType2
             , DataType1
             , DataType2
             , DatasetType1
             , DatasetType2
             ) where

{-| This module is bindings for Chart.js

# Create Chart Object
@docs attachOn

# Draw Chart
@docs line, bar, radar, polarArea, pie, doughnut

# Types of Chart Data
@docs DataType1, DataType2, DatasetType1, DatasetType2

-}

import Native.Chart exposing (..)
import Json.Encode exposing (..)
import List as L exposing (..)

type Chart = Chart

{-| This function calls getContext("2d") of javascript's canvas and construct Chart instance of Chart.js.
Create chart object and attach chart on element selected by id.

    line (attachOn "chart1") { barShowStroke = True } data
-}
attachOn : String -> Chart
attachOn = Native.Chart.chart

{-| Draw line chart.

    line (attachOn "chart1") { barShowStroke = True } data
-}
line : Chart -> a -> DataType1 -> Chart
line chart opts data = Native.Chart.line chart (encodeDataType1 data) opts

{-| Draw bar chart.

    bar (attachOn "chart1") { barShowStroke = True } data
-}
bar : Chart -> a -> DataType1 -> Chart
bar chart opts data = Native.Chart.bar chart (encodeDataType1 data) opts

{-| Draw radar chart.

    radar (attachOn "chart1") { pointDot = False, angleLineWidth = 1 } data
-}
radar : Chart -> a -> DataType1 -> Chart
radar chart opts data = Native.Chart.radar chart (encodeDataType1 data) opts

{-| Draw polarArea chart.

    polarArea (attachOn "chart1") { scaleShowLine = True } data
-}
polarArea : Chart -> a -> DataType2 -> Chart
polarArea chart opts data = Native.Chart.polarArea chart (encodeDataType2 data) opts

{-| Draw pie chart.

    pie (attachOn "chart1") {} data
-}
pie : Chart -> a -> DataType2 -> Chart
pie chart opts data = Native.Chart.pie chart (encodeDataType2 data) opts

{-| Draw doughnut chart.

    doughnut (attachOn "chart1") {} data
-}
doughnut : Chart -> a -> DataType2 -> Chart
doughnut chart opts data = Native.Chart.doughnut chart (encodeDataType2 data) opts

{-| Re-render Chart.

    data x = {
      labels = ["January","February","March","April","May","June","July"],
      datasets = [
       {
         fillColor = "rgba(220,220,220,0.5)",
         strokeColor = "rgba(220,220,220,0.8)",
         highlightFill = "rgba(220,220,220,0.75)",
         highlightStroke = "rgba(220,220,220,1)",
         data = [30, 75, x],
         mLabel = Nothing
       },
      ]
    }
    (\x -> line (attachOn "chart") {} (data x) |> update) <~ sampleOn Mouse.isDown Mouse.x
-}
update : Chart -> Chart
update = Native.Chart.update

{-| Add data to Chart that type is Line, Bar and Radar.

    bar (attachOn "chart") {} data |> addDataType1 [100, 39] "August"
-}
addDataType1 : List Int -> String -> Chart -> Chart
addDataType1 data label chart = Native.Chart.addData chart (encode 0 (list (L.map int data))) label

{-| Add data to Chart that type is Polararea, Pie and Doughnut.

    addDataType2 (polarArea (attachOn "chart")) {value = 50, color = "#46BFBD", highlight = "#5AD3D1", label = "Green"} Nothing
-}
addDataType2 : DatasetType2 -> Maybe Int -> Chart -> Chart
addDataType2 data mIdx chart = case mIdx of
    Just index -> Native.Chart.addData chart (encode 0 (encodeDatasetType2 data)) index
    Nothing -> Native.Chart.addData chart (encode 0 (encodeDatasetType2 data))

{-| This is helper function that encode data for line, bar and radar function.
This function encode DataType1 data to JSON string.
-}
encodeDataType1 : DataType1 -> String
encodeDataType1 { labels, datasets }
    = let encodeLabels : List String -> Value
          encodeLabels = list << L.map string

          encodeDatasetType1 : DatasetType1 -> Value
          encodeDatasetType1 { fillColor, strokeColor, highlightFill, highlightStroke, data, mLabel }
              = let ds : List (String, Value)
                    ds = [
                      ("fillColor", string fillColor)
                    , ("strokeColor", string strokeColor)
                    , ("highlightFill", string highlightFill)
                    , ("highlightStroke", string highlightStroke)
                    , ("data", list <| L.map int data)
                    ]
                in case mLabel of
                     Just label -> object <| ("label", string label) :: ds
                     Nothing -> object ds

      in encode 0 <| object [
         ("labels", encodeLabels labels)
       , ("datasets", list <| L.map encodeDatasetType1 datasets)
      ]

{-| This is helper function that encode data for polarArea, pie and doughnut function.
This function encode DataType2 data to JSON string.
-}
encodeDataType2 : DataType2 -> String
encodeDataType2 = encode 0 << list << L.map encodeDatasetType2

{-| This is helper function that encode DatasetType2 data to JSON Value.
-}
encodeDatasetType2 : DatasetType2 -> Value
encodeDatasetType2 { value, color, highlight, label }
    = object [
        ("value", int value)
      , ("color", string color)
      , ("highlight", string highlight)
      , ("label", string label)
      ]

{-| Data type for line chart, bar chart and radar chart

    -- example
    data : DataType1
    data = {
      labels = ["January","February","March","April","May","June","July"],
      datasets = [
       {
         fillColor = "rgba(220,220,220,0.5)",
         strokeColor = "rgba(220,220,220,0.8)",
         highlightFill = "rgba(220,220,220,0.75)",
         highlightStroke = "rgba(220,220,220,1)",
         data = [30, 34, 67, 12, 96, 75, 39],
         mLabel = Nothing
       },
       {
         fillColor = "rgba(151,187,205,0.5)",
         strokeColor = "rgba(151,187,205,0.8)",
         highlightFill = "rgba(151,187,205,0.75)",
         highlightStroke = "rgba(151,187,205,1)",
         data = [20, 4, 87, 32, 46, 55, 38],
         mLabel = Just "xlabel"
       }
      ]
    }
-}
type alias DataType1 = {
      labels : List String
    , datasets : List DatasetType1
    }

{-| Data type that "datasets" field of DataType1 data.
-}
type alias DatasetType1 = {
      fillColor : String
    , strokeColor : String
    , highlightFill : String
    , highlightStroke : String
    , data : List Int
    , mLabel : Maybe String
    }

{-| Data type for polarArea chart, pie chart and doughnut chart

    -- example
    data : DataType2
    data = [
      {
        value = 300
      , color = "#F7464A"
      , highlight = "#FF5A5E"
      , label = "Red"
      },
      {
        value = 50
      , color = "#46BFBD"
      , highlight = "#5AD3D1"
      , label = "Green"
      },
      {
        value = 150
      , color = "#6BFBD0"
      , highlight = "#AD3D10"
      , label = "hgoe"
      }
    ]
-}
type alias DataType2 = List DatasetType2

{-| Data type that "datasets" field of DataType1 data.
-}
type alias DatasetType2 = {
      value : Int
    , color : String
    , highlight : String
    , label : String
    }
