module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type alias Model =
    { name : String
    , age : String
    , formErrors : List String
    , sentUser : Maybe User
    }


type alias User =
    { name : String, age : Int }


model : Model
model =
    { name = "Joe", age = "33", formErrors = [], sentUser = Nothing }


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
            { model | sentUser = Just user, formErrors = [] }

        Err errs ->
            { model | sentUser = Nothing, formErrors = errs }


type Msg
    = SetName String
    | SetAge String
    | Send


view : Model -> Html Msg
view model =
    div [ class "columns is-centered" ]
        [ div [ class "column is-one-third" ]
            [ model.formErrors |> viewErrors
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


viewErrors errors =
    case errors of
        [] ->
            text ""

        errs ->
            div [ class "notification is-danger" ]
                [ ul []
                    (errs |> List.map (text >> List.singleton >> li []))
                ]



-- errors ->
--    div [ class "notification is-danger" ] [text ]
-- Nothing ->
--     text ""


viewUser =
    Maybe.map (toString >> text >> List.singleton >> pre []) >> Maybe.withDefault (text "")


ifEmpty : String -> String -> Result String String
ifEmpty error =
    mustNotBe String.isEmpty error


mustNotBe : (a -> Bool) -> String -> a -> Result String a
mustNotBe cond err a =
    if a |> cond then
        Err err
    else
        Ok a


mustBe : (a -> Bool) -> String -> a -> Result String a
mustBe cond err a =
    if a |> cond then
        Ok a
    else
        Err err


modelToUser : Model -> Result (List String) User
modelToUser model =
    (Ok User)
        |> validate (model.name |> ifEmpty "Name must not be Empty")
        |> validate
            (model.age
                |> (String.toInt >> Result.mapError (always "Age must be a number"))
                |> Result.andThen (mustBe (\a -> a >= 18) "Age must be over 18.")
            )


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


validate : Result err a -> Result (List err) (a -> b) -> Result (List err) b
validate resA resFn =
    case resFn of
        Ok fn ->
            case resA of
                Ok a ->
                    Ok (fn a)

                Err err ->
                    Err [ err ]

        Err errs ->
            case resA of
                Ok _ ->
                    Err errs

                Err err ->
                    Err (errs ++ [ err ])
