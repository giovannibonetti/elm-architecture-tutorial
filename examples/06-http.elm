module Main exposing (Model, Msg(..), ResponseData, getRandomGif, gifDecoder, init, main, subscriptions, toGiphyUrl, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Url.Builder as Url



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
    { topic : String
    , url : String
    , title : String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model "cat" "waiting.gif" ""
    , getRandomGif "cat"
    )



-- UPDATE


type Msg
    = MorePlease
    | NewGif (Result Http.Error ResponseData)
    | Topic String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MorePlease ->
            ( model
            , getRandomGif model.topic
            )

        NewGif result ->
            case result of
                Ok responseData ->
                    ( { model | url = responseData.url, title = responseData.title }
                    , Cmd.none
                    )

                Err _ ->
                    ( model
                    , Cmd.none
                    )

        Topic topic ->
            ( { model | topic = topic }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ select [ onInput Topic, value model.topic ]
            [ option [ value "cat" ] [ text "cat" ]
            , option [ value "dog" ] [ text "dog" ]
            , option [ value "duck" ] [ text "duck" ]
            ]
        , button [ onClick MorePlease ] [ text "More Please!" ]
        , br [] []
        , h2 [] [ text model.title ]
        , img [ src model.url ] []
        ]



-- HTTP


type alias ResponseData =
    { url : String
    , title : String
    }


getRandomGif : String -> Cmd Msg
getRandomGif topic =
    Http.send NewGif (Http.get (toGiphyUrl topic) gifDecoder)


toGiphyUrl : String -> String
toGiphyUrl topic =
    Url.crossOrigin "https://api.giphy.com"
        [ "v1", "gifs", "random" ]
        [ Url.string "api_key" "dc6zaTOxFJmzC"
        , Url.string "tag" topic
        ]


gifDecoder : Decode.Decoder ResponseData
gifDecoder =
    Decode.map2 ResponseData
        (Decode.field "data" (Decode.field "image_url" Decode.string))
        (Decode.field "data" (Decode.field "title" Decode.string))
