module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Cast exposing (..)


type alias Model =
    { name : String
    , age : String
    , password : String
    , passwordConfirm : String
    , formErrors : List String
    , sentUser : Maybe User
    }


type alias User =
    { name : String, age : Int, password : String }


model : Model
model =
    { name = "Joe"
    , age = "33"
    , password = ""
    , passwordConfirm = ""
    , formErrors = []
    , sentUser = Nothing
    }


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

        SetPassword pwd ->
            { model | password = pwd } ! [ Cmd.none ]

        SetPasswordConfirm pwd ->
            { model | passwordConfirm = pwd } ! [ Cmd.none ]

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
    | SetPassword String
    | SetPasswordConfirm String
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
                , div [ class "field" ]
                    [ label [ class "label" ] [ text "Password" ]
                    , input [ type_ "password", class "input", value model.password, onInput SetPassword ] []
                    ]
                , div [ class "field" ]
                    [ label [ class "label" ] [ text "Password" ]
                    , input [ type_ "password", class "input", value model.passwordConfirm, onInput SetPasswordConfirm ] []
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


modelToUser : Model -> Result (List String) User
modelToUser model =
    (Ok User)
        |> cast (model.name |> mustNotBe String.isEmpty "Name not be empty")
        |> cast
            (model.age
                |> (String.toInt >> Result.mapError (always "Age must be a number"))
                |> Result.andThen (mustBe (\a -> a >= 18) "Age must be over 18.")
            )
        |> cast
            (model.password
                |> mustNotBe (String.isEmpty) "Please enter a password"
                |> Result.andThen (mustBe (\a -> String.length a >= 6) "Password  must be have al least 6 character")
                |> Result.andThen (mustBe ((==) model.passwordConfirm) "Confirm password does not match")
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
