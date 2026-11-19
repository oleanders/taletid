module Main exposing (..)

import Browser
import Browser.Events
import Char
import Html exposing (Attribute, Html, button, div, h1, img, p, span, text)
import Html.Attributes exposing (class, style)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import List
import Time



---- MODEL ----


type alias Model =
    { gjeldendeTid : Int
    , startTid : Int
    , sluttTid : Int
    , nedtelling : Int
    , prosentFerdig : Float
    , valg : List Valg
    , varsel : Bool
    }


type alias Valg =
    { minutter : Int
    , hurtigtast : Int
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { gjeldendeTid = flags.currentTime
      , startTid = flags.currentTime
      , sluttTid = flags.currentTime
      , nedtelling = 0
      , prosentFerdig = 0
      , valg =
            [ Valg 1 (Char.toCode 'R')
            , Valg 2 (Char.toCode 'D')
            , Valg 3 (Char.toCode 'I')
            , Valg 5 (Char.toCode 'H')
            , Valg 10 (Char.toCode 'S')
            , Valg 60 (Char.toCode 'P')
            ]
      , varsel = False
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = OnTime Time.Posix
    | SettMaltid Int
    | Keypress Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnTime t ->
            let
                now =
                    Time.posixToMillis t

                remaining =
                    max 0 (model.sluttTid - now) // 1000

                total =
                    model.sluttTid - model.startTid

                percent =
                    if total <= 0 then
                        100

                    else
                        clamp 0 100 (100 * toFloat (now - model.startTid) / toFloat total)
            in
            ( { model | gjeldendeTid = now, nedtelling = remaining, prosentFerdig = percent, varsel = remaining < 31 }, Cmd.none )

        Keypress key ->
            let
                tid =
                    model.valg
                        |> List.filter (\x -> x.hurtigtast == key)
                        |> List.map (\x -> x.minutter)
                        |> List.head
                        |> Maybe.withDefault 0
                        |> settNySluttTid model.gjeldendeTid
            in
            ( { model | startTid = model.gjeldendeTid, sluttTid = tid }, Cmd.none )

        SettMaltid minutter ->
            let
                nySluttTid =
                    settNySluttTid model.gjeldendeTid minutter
            in
            ( { model | startTid = model.gjeldendeTid, sluttTid = nySluttTid }, Cmd.none )


settNySluttTid : Int -> Int -> Int
settNySluttTid now minutes =
    now + minutes * 60000



---- VIEW ----


view : Model -> Html Msg
view model =
    div
        [ if model.varsel == True then
            class "varsel"

          else
            class ""
        ]
    <|
        List.concat
            [ [ h1 [] [ text "" ]
              , p
                    []
                    [ text <| formaterTidspunkt2 <| model.nedtelling ]
              , viewProgressbar model
              ]
            , List.map viewKnapp model.valg
            , [ button
                    [ onClick <| SettMaltid 0 ]
                    [ text "Nullstill" ]
              ]
            ]


viewKnapp : Valg -> Html Msg
viewKnapp valg =
    button
        [ onClick <| SettMaltid valg.minutter ]
        [ text <| String.fromInt valg.minutter ++ " min" ]


viewProgressbar : Model -> Html Msg
viewProgressbar model =
    div [ class "progressbar" ]
        [ div
            [ if model.varsel == True then
                class "progressvarsel"

              else
                class "progress"
            , style "width" (String.fromFloat model.prosentFerdig ++ "%")
            ]
            []
        ]


formaterTidspunkt2 : Int -> String
formaterTidspunkt2 seconds =
    let
        pad n =
            String.padLeft 2 '0' (String.fromInt n)
    in
    pad (seconds // 60) ++ ":" ++ pad (modBy 60 seconds)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.Events.onKeyDown (Decode.map Keypress (Decode.field "keyCode" Decode.int))
        , Time.every 100 OnTime
        ]



---- PROGRAM ----


type alias Flags =
    { currentTime : Int }


main : Program Flags Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
