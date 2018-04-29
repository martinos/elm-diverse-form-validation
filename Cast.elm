module Cast exposing (..)


cast : Result err a -> Result (List err) (a -> b) -> Result (List err) b
cast resA resFn =
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
