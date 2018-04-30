# Elm-Diverse-Form-Validation

This repo contains examples of multiple form validation technique.

## (SimplestForm.elm)

The simplest form validation uses a simple Result.mapN to cast the form to the desired data format.

```elm
modelToUser : Model -> Result String User
modelToUser model =
    Result.map2 User
        (model.name |> ifEmpty "Name must not be Empty")
        (model.age |> String.toInt |> Result.mapError (always "Age must be a number"))

```

Pros
- Very simple solution. Very easy to implement and to debug 
- Don't need external libraries


Cons
- Validation is made on submit. I think that is in fact a good thing.
- Only one validation is made at a time
- All errors are displayed in a callout. No inline error.

##  (CastValidationForm.elm)

This uses a an applicative functor to do the validation

```elm
modelToUser : Model -> Result (List String) User
modelToUser model =
    (Ok User)
        |> cast (model.name |> mustNotBe String.isEmpty "Name not be empty") -- First param of the User constructor
        |> cast -- Second param of the User constructor
            (model.age
                |> (String.toInt >> Result.mapError (always "Age must be a number"))
                |> Result.andThen (mustBe (\a -> a >= 18) "Age must be over 18.") 
            )
        |> cast -- Last param of the User constructor
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
- Needs the (Cast.elm) file, I would advise to copy it in you app.
- There is only one error that will be displayed per field. Sometime this is ok, since some validation are applied after the casting has been done.  We stop the validation on a given field when we get an error.
- Validation is not displayed inline. They are only displayed in the callout.
- Validation and casting are made at the same time 
