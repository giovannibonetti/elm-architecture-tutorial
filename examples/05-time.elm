module Main exposing (Model, Msg(..), h1Styles, init, main, subscriptions, update, view)

import Browser
import Html exposing (Html, button, div, h1, input, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Svg exposing (circle, rect, svg)
import Svg.Attributes exposing (cx, cy, fill, height, r, rx, ry, stroke, transform, viewBox, width, x, y)
import Task
import Time



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { zone : Time.Zone
    , time : Time.Posix
    , paused : Bool
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Time.utc (Time.millisToPosix 0) False
    , Task.perform AdjustTimeZone Time.here
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone
    | Pause


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( { model | time = newTime }
            , Cmd.none
            )

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }
            , Cmd.none
            )

        Pause ->
            ( { model | paused = not model.paused }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    if model.paused then
        Sub.none

    else
        Time.every 1000 Tick



-- VIEW


h1Styles =
    [ style "border" "1px solid"
    , style "width" "125px"
    , style "padding" "3px 1px 3px 9px"
    ]


view : Model -> Html Msg
view model =
    let
        paddedStr int =
            String.padLeft 2 '0' (String.fromInt int)

        hourInt =
            Time.toHour model.zone model.time

        minuteInt =
            Time.toMinute model.zone model.time

        secondInt =
            Time.toSecond model.zone model.time

        hourStr =
            paddedStr hourInt

        minuteStr =
            paddedStr minuteInt

        secondStr =
            paddedStr secondInt

        hourAngle =
            hourInt * 360 // 12 - 180

        minuteAngle =
            minuteInt * 360 // 60 - 180

        secondAngle =
            secondInt * 360 // 60 - 180
    in
    div []
        [ h1 h1Styles [ text (hourStr ++ ":" ++ minuteStr ++ ":" ++ secondStr) ]
        , button [ onClick Pause ] [ text "Pause" ]
        , svg
            [ width "120"
            , height "120"
            , viewBox "0 0 120 120"
            ]
            [ circle
                [ fill "white"
                , stroke "black"
                , cx "50"
                , cy "50"
                , r "50"
                ]
                []
            , rect
                [ x "0"
                , y "0"
                , width "1"
                , height "50"
                , fill "red"
                , stroke "red"
                , transform ("translate(50, 50) rotate(" ++ String.fromInt secondAngle ++ ")")
                , rx "1"
                , ry "1"
                ]
                []
            , rect
                [ x "0"
                , y "0"
                , width "5"
                , height "50"
                , transform ("translate(50, 50) rotate(" ++ String.fromInt minuteAngle ++ ")")
                , rx "3"
                , ry "3"
                ]
                []
            , rect
                [ x "0"
                , y "0"
                , width "5"
                , height "25"
                , transform ("translate(50, 50) rotate(" ++ String.fromInt hourAngle ++ ")")
                , rx "3"
                , ry "3"
                ]
                []
            ]
        ]
