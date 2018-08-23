import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)



-- MAIN


main =
  Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
  { name : String
  , password : String
  , passwordAgain : String
  , age : Maybe Int
  , showValidation: Bool
  }


init : Model
init =
  Model "" "" "" Nothing False



-- UPDATE


type Msg
  = Name String
  | Password String
  | PasswordAgain String
  | Age(Maybe Int)
  | Submit


update : Msg -> Model -> Model
update msg model =
  case msg of
    Name name ->
      { model | name = name }

    Password password ->
      { model | password = password }

    PasswordAgain password ->
      { model | passwordAgain = password }

    Age age ->
      { model | age = age }

    Submit ->
      { model | showValidation = True }


-- VIEW


view : Model -> Html Msg
view model =
  let
    ageString = model.age |> maybeIntToString
    ageFromString str =
      if str == "" then
        Age Nothing
      else
        Age(String.toInt str)
  in
    div []
      [ viewInput "text" "Name" model.name Name
      , viewInput "password" "Password" model.password Password
      , viewInput "password" "Re-enter Password" model.passwordAgain PasswordAgain
      , viewInput "age" "Age" ageString ageFromString
      , button [ onClick Submit ] [ text "Submit" ]
      , viewValidation model
      ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [ type_ t, placeholder p, value v, onInput toMsg ] []

maybeIntToString : Maybe Int -> String
maybeIntToString intOrString =
  case intOrString of
    Nothing -> ""
    Just int -> String.fromInt int

viewValidation : Model -> Html msg
viewValidation model =
  let
    okMessageIfEmpty : List (Html msg) -> List (Html msg)
    okMessageIfEmpty list =
      if List.isEmpty list then
        [ div [ style "color" "green" ] [ text "OK" ] ]
      else
        list
    showValidationFilter (_) = model.showValidation
  in
    [
      (
        model.age == Nothing,
        div [ style "color" "red" ] [ text "Age must be provided!" ]
      ), (
        String.isEmpty model.password,
        div [ style "color" "red" ] [ text "Password is required!" ]
      ), (
        String.length model.password < 8,
          div [ style "color" "red" ] [ text "Password is too short!" ]
      ), (
        model.password /= model.passwordAgain,
        div [ style "color" "red" ] [ text "Passwords do not match!" ]
      )
    ] |> List.filter Tuple.first
      |> List.map Tuple.second
      |> okMessageIfEmpty
      |> List.filter showValidationFilter
      |> div []
