module DelgetionTest exposing (suite)

import ConnectWallet
import Delegation
import Dropdown
import Element
import Expect
import Test
import Test.Html.Query
import Test.Html.Selector


suite : Test.Test
suite =
    Test.describe "Delegation Tests"
        [ Test.test "test GetAccountStatus with ConnectionEstablished" <|
            \_ ->
                let
                    initialModel : Delegation.Model
                    initialModel =
                        Delegation.WalletState ""
                            (ConnectWallet.ConnectionEstablished Element.none
                                [ ConnectWallet.Nami ]
                                (Dropdown.init "wallet-dropdown")
                                (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            )

                    ( newModel, _ ) =
                        Delegation.update Delegation.GetAccountStatus initialModel
                in
                Expect.equal
                    newModel
                    (Delegation.GettingAcountStatus
                        (ConnectWallet.ConnectionEstablished Element.none
                            [ ConnectWallet.Nami ]
                            (Dropdown.init "wallet-dropdown")
                            (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                        )
                        ""
                        (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                    )
        , Test.test "test ReceiveAccountStatus with GettingAcountStatus" <|
            \_ ->
                let
                    initialModel : Delegation.Model
                    initialModel =
                        Delegation.GettingAcountStatus
                            (ConnectWallet.ConnectionEstablished Element.none
                                [ ConnectWallet.Nami ]
                                (Dropdown.init "wallet-dropdown")
                                (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            )
                            ""
                            (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)

                    account : Delegation.Account
                    account =
                        { stake_address = "", pool_id = "", active = True }

                    ( newModel, _ ) =
                        Delegation.update (Delegation.ReceiveAccountStatus (Result.Ok account)) initialModel
                in
                Expect.equal
                    newModel
                    (Delegation.Connected
                        (ConnectWallet.ConnectionEstablished Element.none
                            [ ConnectWallet.Nami ]
                            (Dropdown.init "wallet-dropdown")
                            (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                        )
                        ""
                        (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                        account
                        Delegation.DelegatingToSumn
                    )
        , Test.test "test RegisterAndDelegateToSumn with Connected" <|
            \_ ->
                let
                    account : Delegation.Account
                    account =
                        { stake_address = "", pool_id = "", active = True }

                    initialModel : Delegation.Model
                    initialModel =
                        Delegation.Connected
                            (ConnectWallet.ConnectionEstablished Element.none
                                [ ConnectWallet.Nami ]
                                (Dropdown.init "wallet-dropdown")
                                (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            )
                            ""
                            (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            account
                            Delegation.NotDelegating

                    ( newModel, _ ) =
                        Delegation.update Delegation.RegisterAndDelegateToSumn initialModel
                in
                Expect.equal
                    newModel
                    (Delegation.RegisteringAndDelegating
                        (ConnectWallet.ConnectionEstablished Element.none
                            [ ConnectWallet.Nami ]
                            (Dropdown.init "wallet-dropdown")
                            (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                        )
                        ""
                        (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                        account
                    )
        , Test.test "test ReceiveRegisterAndDelegateStatus with Connected NotDelegating" <|
            \_ ->
                let
                    account : Delegation.Account
                    account =
                        { stake_address = "", pool_id = "", active = True }

                    initialModel : Delegation.Model
                    initialModel =
                        Delegation.RegisteringAndDelegating
                            (ConnectWallet.ConnectionEstablished Element.none
                                [ ConnectWallet.Nami ]
                                (Dropdown.init "wallet-dropdown")
                                (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            )
                            ""
                            (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            account

                    ( newModel, _ ) =
                        Delegation.update (Delegation.ReceiveRegisterAndDelegateStatus True) initialModel
                in
                Expect.equal
                    newModel
                    (Delegation.Connected
                        (ConnectWallet.ConnectionEstablished Element.none
                            [ ConnectWallet.Nami ]
                            (Dropdown.init "wallet-dropdown")
                            (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                        )
                        ""
                        (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                        account
                        Delegation.DelegatingToSumn
                    )
        , Test.test "test UndelegateFromSumn with Connected DelegatingToSumn" <|
            \_ ->
                let
                    account : Delegation.Account
                    account =
                        { stake_address = "", pool_id = "", active = True }

                    initialModel : Delegation.Model
                    initialModel =
                        Delegation.Connected
                            (ConnectWallet.ConnectionEstablished Element.none
                                [ ConnectWallet.Nami ]
                                (Dropdown.init "wallet-dropdown")
                                (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            )
                            ""
                            (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            account
                            Delegation.DelegatingToSumn

                    ( newModel, _ ) =
                        Delegation.update Delegation.UndelegateFromSumn initialModel
                in
                Expect.equal
                    newModel
                    (Delegation.Undelegating
                        (ConnectWallet.ConnectionEstablished Element.none
                            [ ConnectWallet.Nami ]
                            (Dropdown.init "wallet-dropdown")
                            (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                        )
                        ""
                        (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                        account
                    )
        , Test.test "test ReceiveUndelegateStatus with Undelegating" <|
            \_ ->
                let
                    account : Delegation.Account
                    account =
                        { stake_address = "", pool_id = "", active = True }

                    initialModel : Delegation.Model
                    initialModel =
                        Delegation.Undelegating
                            (ConnectWallet.ConnectionEstablished Element.none
                                [ ConnectWallet.Nami ]
                                (Dropdown.init "wallet-dropdown")
                                (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            )
                            ""
                            (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            account

                    ( newModel, _ ) =
                        Delegation.update (Delegation.ReceiveUndelegateStatus True) initialModel
                in
                Expect.equal
                    newModel
                    (Delegation.Connected
                        (ConnectWallet.ConnectionEstablished Element.none
                            [ ConnectWallet.Nami ]
                            (Dropdown.init "wallet-dropdown")
                            (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                        )
                        ""
                        (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                        account
                        Delegation.NotDelegating
                    )
        , Test.test "test Delegate with Connected DelegatingToOther" <|
            \_ ->
                let
                    account : Delegation.Account
                    account =
                        { stake_address = "", pool_id = "", active = True }

                    initialModel : Delegation.Model
                    initialModel =
                        Delegation.Connected
                            (ConnectWallet.ConnectionEstablished Element.none
                                [ ConnectWallet.Nami ]
                                (Dropdown.init "wallet-dropdown")
                                (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            )
                            ""
                            (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            account
                            Delegation.DelegatingToOther

                    ( newModel, _ ) =
                        Delegation.update Delegation.DelegateToSumn initialModel
                in
                Expect.equal
                    newModel
                    (Delegation.Delegating
                        (ConnectWallet.ConnectionEstablished Element.none
                            [ ConnectWallet.Nami ]
                            (Dropdown.init "wallet-dropdown")
                            (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                        )
                        ""
                        (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                        account
                    )
        , Test.test "test ReceiveDelegateStatus with Connected DelegatingToOther" <|
            \_ ->
                let
                    account : Delegation.Account
                    account =
                        { stake_address = "", pool_id = "", active = True }

                    initialModel : Delegation.Model
                    initialModel =
                        Delegation.Delegating
                            (ConnectWallet.ConnectionEstablished Element.none
                                [ ConnectWallet.Nami ]
                                (Dropdown.init "wallet-dropdown")
                                (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            )
                            ""
                            (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            account

                    ( newModel, _ ) =
                        Delegation.update (Delegation.ReceiveDelegateToSumnStatus True) initialModel
                in
                Expect.equal
                    newModel
                    (Delegation.Connected
                        (ConnectWallet.ConnectionEstablished Element.none
                            [ ConnectWallet.Nami ]
                            (Dropdown.init "wallet-dropdown")
                            (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                        )
                        ""
                        (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                        account
                        Delegation.DelegatingToSumn
                    )
        , Test.test "test GettingAcountStatus view" <|
            \_ ->
                let
                    initialModel : Delegation.Model
                    initialModel =
                        Delegation.GettingAcountStatus
                            (ConnectWallet.ConnectionEstablished Element.none
                                [ ConnectWallet.Nami ]
                                (Dropdown.init "wallet-dropdown")
                                (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            )
                            ""
                            (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                in
                Test.Html.Query.fromHtml (Delegation.view initialModel)
                    |> Test.Html.Query.find [ Test.Html.Selector.id "delegationButton" ]
                    |> Test.Html.Query.has
                        [ Test.Html.Selector.all
                            [ Test.Html.Selector.disabled True
                            , Test.Html.Selector.text "Getting account status"
                            ]
                        ]
        , Test.test "test Connected NotDelegating view" <|
            \_ ->
                let
                    account : Delegation.Account
                    account =
                        { stake_address = "", pool_id = "", active = True }

                    initialModel : Delegation.Model
                    initialModel =
                        Delegation.Connected
                            (ConnectWallet.ConnectionEstablished Element.none
                                [ ConnectWallet.Nami ]
                                (Dropdown.init "wallet-dropdown")
                                (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            )
                            ""
                            (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            account
                            Delegation.NotDelegating
                in
                Test.Html.Query.fromHtml (Delegation.view initialModel)
                    |> Test.Html.Query.find [ Test.Html.Selector.id "delegationButton" ]
                    |> Test.Html.Query.has
                        [ Test.Html.Selector.text "Register and Delegate"
                        ]
        , Test.test "test Connected DelegatingToOther view" <|
            \_ ->
                let
                    account : Delegation.Account
                    account =
                        { stake_address = "", pool_id = "", active = True }

                    initialModel : Delegation.Model
                    initialModel =
                        Delegation.Connected
                            (ConnectWallet.ConnectionEstablished Element.none
                                [ ConnectWallet.Nami ]
                                (Dropdown.init "wallet-dropdown")
                                (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            )
                            ""
                            (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            account
                            Delegation.DelegatingToOther
                in
                Test.Html.Query.fromHtml (Delegation.view initialModel)
                    |> Test.Html.Query.find [ Test.Html.Selector.id "delegationButton" ]
                    |> Test.Html.Query.has
                        [ Test.Html.Selector.text "Delegate"
                        ]
        , Test.test "test Connected DelegatingToSumn view" <|
            \_ ->
                let
                    account : Delegation.Account
                    account =
                        { stake_address = "", pool_id = "", active = True }

                    initialModel : Delegation.Model
                    initialModel =
                        Delegation.Connected
                            (ConnectWallet.ConnectionEstablished Element.none
                                [ ConnectWallet.Nami ]
                                (Dropdown.init "wallet-dropdown")
                                (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            )
                            ""
                            (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            account
                            Delegation.DelegatingToSumn
                in
                Test.Html.Query.fromHtml (Delegation.view initialModel)
                    |> Test.Html.Query.find [ Test.Html.Selector.id "delegationButton" ]
                    |> Test.Html.Query.has
                        [ Test.Html.Selector.text "Undelegate"
                        ]
        , Test.test "test RegisteringAndDelegating view" <|
            \_ ->
                let
                    account : Delegation.Account
                    account =
                        { stake_address = "", pool_id = "", active = True }

                    initialModel : Delegation.Model
                    initialModel =
                        Delegation.RegisteringAndDelegating
                            (ConnectWallet.ConnectionEstablished Element.none
                                [ ConnectWallet.Nami ]
                                (Dropdown.init "wallet-dropdown")
                                (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            )
                            ""
                            (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            account
                in
                Test.Html.Query.fromHtml (Delegation.view initialModel)
                    |> Test.Html.Query.find [ Test.Html.Selector.id "delegationButton" ]
                    |> Test.Html.Query.has
                        [ Test.Html.Selector.all
                            [ Test.Html.Selector.disabled True
                            , Test.Html.Selector.text "Registering and Delegating"
                            ]
                        ]
        , Test.test "test Delegating view" <|
            \_ ->
                let
                    account : Delegation.Account
                    account =
                        { stake_address = "", pool_id = "", active = True }

                    initialModel : Delegation.Model
                    initialModel =
                        Delegation.Delegating
                            (ConnectWallet.ConnectionEstablished Element.none
                                [ ConnectWallet.Nami ]
                                (Dropdown.init "wallet-dropdown")
                                (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            )
                            ""
                            (ConnectWallet.EnabledSupportedWallet ConnectWallet.Nami)
                            account
                in
                Test.Html.Query.fromHtml (Delegation.view initialModel)
                    |> Test.Html.Query.find [ Test.Html.Selector.id "delegationButton" ]
                    |> Test.Html.Query.has
                        [ Test.Html.Selector.all
                            [ Test.Html.Selector.disabled True
                            , Test.Html.Selector.text "Delegating"
                            ]
                        ]
        ]
