import Browser
import Html exposing (..)
import Html.Events exposing (onClick)
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


init : () -> (Model, Cmd Msg)
init _ =
  ( Model Time.utc (Time.millisToPosix 0) False
  , Task.perform AdjustTimeZone Time.here
  )



-- UPDATE


type Msg
  = Tick Time.Posix
  | AdjustTimeZone Time.Zone
  | Pause


update : Msg -> Model -> (Model, Cmd Msg)
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
      ( { model | paused = (not model.paused) }
      , Cmd.none
      )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  if model.paused then
    Time.every 1000000000 Tick
  else
    Time.every 1000 Tick



-- VIEW


view : Model -> Html Msg
view model =
  let
    intToPaddedStr int = String.padLeft 2 '0' (String.fromInt int)
    hour   = intToPaddedStr (Time.toHour   model.zone model.time)
    minute = intToPaddedStr (Time.toMinute model.zone model.time)
    second = intToPaddedStr (Time.toSecond model.zone model.time)
  in
    div []
      [ h1 [] [ text (hour ++ ":" ++ minute ++ ":" ++ second) ]
      ,  button [ onClick Pause ] [ text "Pause" ]
      ]