module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Model =
    { name : String
    , age : String
    , formError : Maybe String
    , sentUser : Maybe User
    }


type alias User =
    { name : String, age : Int }


model : Model
model =
    { name = "Joe", age = "33", formError = Nothing, sentUser = Nothing }


main =
    Html.program
        { init = ( model, Cmd.none )
        , update = update
        , view = view >> layout
        , subscriptions = always Sub.none
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetName name ->
            { model | name = name } ! [ Cmd.none ]

        SetAge age ->
            { model | age = age } ! [ Cmd.none ]

        Send ->
            (model |> sendModel) ! [ Cmd.none ]


sendModel : Model -> Model
sendModel model =
    case model |> modelToUser of
        Ok user ->
            { model | sentUser = Just user, formError = Nothing }

        Err err ->
            { model | sentUser = Nothing, formError = Just err }


type Msg
    = SetName String
    | SetAge String
    | Send


view : Model -> Html Msg
view model =
    div [ class "columns" ]
        [ div [ class "column is-one-third" ]
            [ model.formError |> viewError
            , Html.form [ action "javscript: void(0);", onSubmit Send ]
                [ div [ class "field" ]
                    [ label [ class "label" ] [ text "Name" ]
                    , input [ type_ "text", class "input", value model.name, onInput SetName ] []
                    ]
                , div [ class "field" ]
                    [ label [ class "label" ] [ text "Age" ]
                    , input [ type_ "text", class "input", value model.age, onInput SetAge ] []
                    ]
                , div [ class "control" ]
                    [ button [ class "button is-primary", type_ "submit" ] [ text "Send" ] ]
                ]
            , model.sentUser |> viewUser
            ]
        ]


viewError error =
    case error of
        Just error ->
            div [ class "notification is-danger" ] [ error |> text ]

        Nothing ->
            text ""


viewUser =
    Maybe.map (toString >> text >> List.singleton >> pre []) >> Maybe.withDefault (text "")


ifEmpty : String -> String -> Result String String
ifEmpty error str =
    if str |> String.isEmpty then
        Err error
    else
        Ok str


modelToUser : Model -> Result String User
modelToUser model =
    Result.map2 User
        (model.name |> ifEmpty "Name must not be Empty")
        (model.age |> String.toInt |> Result.mapError (always "Age must be a number"))


layout : Html msg -> Html msg
layout inner =
    div []
        [ bulma
        , section [ class "section" ]
            [ inner ]
        ]


bulma =
    div []
        [ node "meta" [ name "viewport", content "width=device-width, initial-scale=1" ] []
        , node "link" [ rel "stylesheet", href "https://cdnjs.cloudflare.com/ajax/libs/bulma/0.6.2/css/bulma.min.css" ] []
        ]
