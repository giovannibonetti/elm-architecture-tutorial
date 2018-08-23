import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Random



-- MAIN


main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }



-- MODEL


type alias Model =
  { dieFace1 : Int
  , dieFace2 : Int
  }


init : () -> (Model, Cmd Msg)
init _ =
  ( Model 1 6
  , Cmd.none
  )



-- UPDATE


type Msg
  = Roll
  | NewFaces (Int, Int)

-- https://stackoverflow.com/questions/37227421/how-do-i-add-a-second-die-to-this-elm-effects-example#answer-37228575
dieGenerator : Random.Generator Int
dieGenerator =
  Random.int 1 6

diePairGenerator : Random.Generator (Int, Int)
diePairGenerator =
  Random.pair dieGenerator dieGenerator

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Roll ->
      ( model
      , Random.generate NewFaces diePairGenerator
      )

    NewFaces (newFace1, newFace2) ->
      ( Model newFace1 newFace2
      , Cmd.none
      )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW

h1Styles =
  [ style "border" "1px solid"
  , style "width" "25px"
  , style "padding" "3px 1px 3px 9px"
  ]

view : Model -> Html Msg
view model =
  div []
    [ h1 h1Styles [ text (String.fromInt model.dieFace1) ]
    , h1 h1Styles [ text (String.fromInt model.dieFace2) ]
    , button [ onClick Roll ] [ text "Roll" ]
    ]