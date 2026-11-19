module Tests exposing (all)

import Expect
import Main exposing (formaterTidspunkt2, settNySluttTid)
import Test exposing (Test, describe, test)


all : Test
all =
    describe "Nedtelling"
        [ test "viser minutt og sekund" <| \_ -> Expect.equal "01:01" (formaterTidspunkt2 61)
        , test "legger til valgte minutter" <| \_ -> Expect.equal 121000 (settNySluttTid 1000 2)
        ]
