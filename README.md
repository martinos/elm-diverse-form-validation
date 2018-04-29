# Elm-Diverse-Form-Validation

This repo contains multiple example of validation technique for form validation

## SimplestForm.elm

The simplest form validation uses a simple Result.map to cast the form to the desired data format.

```elm
modelToUser : Model -> Result String User
modelToUser model =
    Result.map2 User
        (model.name |> ifEmpty "Name must not be Empty")
        (model.age |> String.toInt |> Result.mapError (always "Age must be a number"))

```

Pros
- Very simple solution. Easier to implement and easier to debug
- Don't need external libraries


Cons
- validation is made on submit. I think that is in fact a good thing.
- Only one validation is made at a time
- All errors are displayed in a callout. No inline error.

##  CastValidationForm.elm


This uses a an applicative functor to do the validation

```elm
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
```

Pros
- Still a simple solution
- Can display multiple errors at the same time 

Cons
- There is only one error that will be displayed per field. Sometime this is ok, since some validation are appied after the casting has been done.  We stop the validation on a given field when we get an error.
- Validation is not displayed inline. They are  only displayed in the callout.
- Validation and casting are made at the same time 
