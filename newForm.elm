module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Cast exposing (..)


type alias Model =
    { firstName : String
    , lastName : String
    , age : String
    , password : String
    , passwordConfirm : String
    , errors : List String
    , user : Maybe User
    }


type alias User =
    { firstName : String, lastName : String, age : Int, password : String }


user : User
user =
    { firstName = "Bob", lastName = "St-Jean", age = 23, password = "secret" }


model : Model
model =
    { firstName = "Martin"
    , lastName = "Chabot"
    , age = "34"
    , password = "secret"
    , passwordConfirm = "secret"
    , errors = [ "CALINNE" ]
    , user = Just user
    }


main =
    Html.beginnerProgram { model = model, update = update, view = view }


type Msg
    = SetFirstName String
    | SetLastName String
    | SetAge String
    | SetPassword String
    | SetPasswordConfirm String
    | SignUp


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetFirstName str ->
            { model | firstName = str }

        SetLastName str ->
            { model | lastName = str }

        SetAge str ->
            { model | age = str }

        SetPassword str ->
            { model | password = str }

        SetPasswordConfirm str ->
            { model | passwordConfirm = str }

        SignUp ->
            case model |> modelToUser of
                Ok user ->
                    { model | user = Just user, errors = [] }

                Err errors ->
                    { model | user = Nothing, errors = errors }


modelToUser : Model -> Result (List String) User
modelToUser model =
    (Ok User)
        |> cast (model.firstName |> mustNotBe String.isEmpty "First Name must not be empty")
        |> cast (model.lastName |> mustNotBe String.isEmpty "Last Name must not be empty")
        |> cast (model.age |> String.toInt)
        |> cast (model.password |> mustNotBe String.isEmpty "Password must not be empty")


view : Model -> Html Msg
view model =
    div []
        [ bulma
        , section [ class "section" ]
            [ div [ class "container" ]
                [ div [ class "columns" ]
                    [ div [ class "column" ]
                        [ viewErrors model.errors
                        , userForm model
                        , model.user |> Maybe.map viewUser |> Maybe.withDefault (text "")
                        ]
                    ]
                ]
            ]
        ]


viewErrors : List String -> Html msg
viewErrors errors =
    case errors of
        [] ->
            text ""

        errs ->
            div [ class "notification is-danger" ]
                [ ul [] (errs |> List.map (text >> List.singleton >> li [])) ]


viewUser : User -> Html msg
viewUser user =
    user |> toString |> text |> List.singleton |> pre []


userForm : Model -> Html Msg
userForm model =
    Html.form [ action "javascript: void(0)", onSubmit SignUp ]
        [ div [ class "field" ]
            [ label [ class "label" ] [ text "First Name" ]
            , div [ class "control" ]
                [ input [ class "input", type_ "text", value model.firstName, onInput SetFirstName ] [] ]
            ]
        , div [ class "field" ]
            [ label [ class "label" ] [ text "Last Name" ]
            , div [ class "control" ]
                [ input [ class "input", type_ "text", value model.lastName, onInput SetLastName ] [] ]
            ]
        , div [ class "field" ]
            [ label [ class "label" ] [ text "Age" ]
            , div [ class "control" ]
                [ input [ class "input", type_ "number", value model.age, onInput SetAge ] [] ]
            ]
        , div [ class "field" ]
            [ label [ class "label" ] [ text "Password" ]
            , div [ class "control" ]
                [ input [ class "input", type_ "password", value model.password, onInput SetPassword ] [] ]
            ]
        , div [ class "field" ]
            [ label [ class "label" ] [ text "Password Confirm" ]
            , div [ class "control" ]
                [ input [ class "input", type_ "password", value model.passwordConfirm, onInput SetPasswordConfirm ] [] ]
            ]
        , button [ class "button is-primary", onSubmit SignUp ] [ text "SignUp" ]
        ]


bulma =
    div []
        [ node "meta" [ name "viewport", content "width=device-width, initial-scale=1" ] []
        , node "link" [ rel "stylesheet", href "https://cdnjs.cloudflare.com/ajax/libs/bulma/0.6.2/css/bulma.min.css" ] []
        ]
