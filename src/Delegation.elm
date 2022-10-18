port module Delegation exposing
    ( Account
    , DelegationStatus(..)
    , Model(..)
    , Msg(..)
    , PoolId
    , TransactionSuccessStatus
    , main
    , update
    , view
    )

import Browser
import ConnectWallet
import Dropdown
import Element
import Element.Background
import Element.Border
import Element.Input
import Html
import Html.Attributes
import Json.Decode
import Json.Decode.Pipeline
import Maybe.Extra


type alias TransactionSuccessStatus =
    Bool


type alias PoolId =
    String


decodeAccount : Json.Decode.Decoder Account
decodeAccount =
    Json.Decode.succeed Account
        |> Json.Decode.Pipeline.required "stake_address" Json.Decode.string
        |> Json.Decode.Pipeline.optional "pool_id" Json.Decode.string ""
        |> Json.Decode.Pipeline.required "active" Json.Decode.bool


type alias Account =
    { stake_address : String
    , pool_id : PoolId
    , active : Bool
    }


type Msg
    = ConnectW ConnectWallet.Msg
    | NoOp
    | GetAccountStatus
    | ReceiveAccountStatus (Result Json.Decode.Error Account)
    | RegisterAndDelegateToSumn
    | ReceiveRegisterAndDelegateStatus TransactionSuccessStatus
    | DelegateToSumn
    | ReceiveDelegateToSumnStatus TransactionSuccessStatus
    | UndelegateFromSumn
    | ReceiveUndelegateStatus TransactionSuccessStatus


type DelegationStatus
    = NotDelegating
    | DelegatingToSumn
    | DelegatingToOther


type Model
    = WalletState PoolId ConnectWallet.Model
    | GettingAcountStatus ConnectWallet.Model PoolId ConnectWallet.EnabledSupportedWallet
    | Connected ConnectWallet.Model PoolId ConnectWallet.EnabledSupportedWallet Account DelegationStatus
    | RegisteringAndDelegating ConnectWallet.Model PoolId ConnectWallet.EnabledSupportedWallet Account
    | Delegating ConnectWallet.Model PoolId ConnectWallet.EnabledSupportedWallet Account
    | Undelegating ConnectWallet.Model PoolId ConnectWallet.EnabledSupportedWallet Account
    | NullState


init : ( List String, PoolId ) -> ( Model, Cmd Msg )
init ( walletsInstalledAndEnabledStrings, sumnPoolId ) =
    case walletsInstalledAndEnabledStrings of
        [] ->
            ( WalletState sumnPoolId ConnectWallet.NotConnectedNotAbleTo, Cmd.none )

        _ ->
            let
                walletsInstalledAndEnabled : List ConnectWallet.SupportedWallet
                walletsInstalledAndEnabled =
                    List.map ConnectWallet.decodeWallet walletsInstalledAndEnabledStrings
                        |> Maybe.Extra.values

                ( newWalletModel, newWalletCmd ) =
                    ConnectWallet.update ConnectWallet.ChooseWallet
                        (ConnectWallet.NotConnectedButWalletsInstalledAndEnabled
                            (Element.image
                                [ Element.width (Element.px 200)
                                , Element.height (Element.px 50)
                                ]
                                { src = "./select wallet.png"
                                , description = "select wallet"
                                }
                            )
                            walletsInstalledAndEnabled
                        )
            in
            ( WalletState sumnPoolId
                newWalletModel
            , Cmd.map ConnectW newWalletCmd
            )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ConnectW walletMsg, WalletState sumnPoolId walletModel ) ->
            let
                ( newWalletModel, newWalletCmd ) =
                    ConnectWallet.update walletMsg walletModel
            in
            case newWalletModel of
                ConnectWallet.ConnectionEstablished _ _ _ _ ->
                    update GetAccountStatus (WalletState sumnPoolId newWalletModel)

                _ ->
                    ( WalletState sumnPoolId newWalletModel
                    , Cmd.map ConnectW newWalletCmd
                    )

        ( ConnectW walletMsg, Connected walletModel sumnPoolId _ _ _ ) ->
            let
                ( newWalletModel, newWalletCmd ) =
                    ConnectWallet.update walletMsg walletModel
            in
            ( WalletState sumnPoolId newWalletModel, Cmd.map ConnectW newWalletCmd )

        ( GetAccountStatus, WalletState sumnPoolId (ConnectWallet.ConnectionEstablished selectWalletElement walletsInstalled dropdownState w) ) ->
            ( GettingAcountStatus (ConnectWallet.ConnectionEstablished selectWalletElement walletsInstalled dropdownState w) sumnPoolId w, getAccountStatus () )

        ( ReceiveAccountStatus account, GettingAcountStatus dropdownState sumnPoolId wallet ) ->
            ( case account of
                Ok acc ->
                    Connected dropdownState
                        sumnPoolId
                        wallet
                        acc
                        (if acc.active == False then
                            NotDelegating

                         else if acc.active && acc.pool_id /= sumnPoolId then
                            DelegatingToOther

                         else if acc.active && acc.pool_id == sumnPoolId then
                            DelegatingToSumn

                         else
                            NotDelegating
                        )

                Err _ ->
                    NullState
            , Cmd.none
            )

        ( RegisterAndDelegateToSumn, Connected dropdownState p w account NotDelegating ) ->
            ( RegisteringAndDelegating dropdownState p w account, registerAndDelegateToSumn account.stake_address )

        ( ReceiveRegisterAndDelegateStatus result, RegisteringAndDelegating dropdownState p w account ) ->
            if result then
                let
                    newModel : Model
                    newModel =
                        if result then
                            Connected dropdownState p w account DelegatingToSumn

                        else
                            Connected dropdownState p w account NotDelegating
                in
                ( newModel
                , Cmd.none
                )

            else
                ( NullState
                , Cmd.none
                )

        ( DelegateToSumn, Connected dropdownState p w account DelegatingToOther ) ->
            ( Delegating dropdownState p w account, delegateToSumn account.stake_address )

        ( ReceiveDelegateToSumnStatus result, Delegating dropdownState p w account ) ->
            let
                newModel : Model
                newModel =
                    if result then
                        Connected dropdownState p w account DelegatingToSumn

                    else
                        Connected dropdownState p w account NotDelegating
            in
            ( newModel
            , Cmd.none
            )

        ( UndelegateFromSumn, Connected dropdownState p w account DelegatingToSumn ) ->
            ( Undelegating dropdownState p w account, undelegate account.stake_address )

        ( ReceiveUndelegateStatus result, Undelegating dropdownState p w account ) ->
            let
                newModel : Model
                newModel =
                    if result then
                        Connected dropdownState p w account NotDelegating

                    else
                        Connected dropdownState p w account DelegatingToSumn
            in
            ( newModel
            , Cmd.none
            )

        _ ->
            ( model, Cmd.none )


view : Model -> Html.Html Msg
view model =
    let
        id : Element.Attribute msg
        id =
            Element.htmlAttribute (Html.Attributes.id "delegationButton")
    in
    case model of
        WalletState _ ws ->
            Html.map ConnectW (ConnectWallet.view (Element.rgb255 0 0 0) ws)

        GettingAcountStatus _ _ _ ->
            Element.layout []
                (Element.Input.button
                    [ Element.Background.color buttonHoverColor
                    , Element.htmlAttribute (Html.Attributes.disabled True)
                    , id
                    ]
                    { onPress =
                        Just
                            NoOp
                    , label =
                        Element.text
                            "Getting account status"
                    }
                )

        Connected dropdownState _ _ _ d ->
            case d of
                NotDelegating ->
                    Element.layout []
                        (Element.column
                            []
                            [ Element.html (Html.map ConnectW (ConnectWallet.view (Element.rgb255 0 0 0) dropdownState))
                            , Element.Input.button
                                [ Element.Background.color buttonHoverColor
                                , Element.mouseOver
                                    [ Element.Border.glow buttonHoverColor
                                        10
                                    ]
                                , id
                                ]
                                { onPress =
                                    Just
                                        RegisterAndDelegateToSumn
                                , label =
                                    Element.text
                                        "Register and Delegate"
                                }
                            ]
                        )

                DelegatingToOther ->
                    Element.layout []
                        (Element.column
                            []
                            [ Element.html (Html.map ConnectW (ConnectWallet.view (Element.rgb255 0 0 0) dropdownState))
                            , Element.Input.button
                                [ Element.Background.color buttonHoverColor
                                , Element.mouseOver
                                    [ Element.Border.glow buttonHoverColor
                                        10
                                    ]
                                , id
                                ]
                                { onPress =
                                    Just
                                        DelegateToSumn
                                , label =
                                    Element.text
                                        "Delegate"
                                }
                            ]
                        )

                DelegatingToSumn ->
                    Element.layout []
                        (Element.column
                            []
                            [ Element.html (Html.map ConnectW (ConnectWallet.view (Element.rgb255 0 0 0) dropdownState))
                            , Element.Input.button
                                [ Element.Background.color buttonHoverColor
                                , id
                                ]
                                { onPress =
                                    Just
                                        UndelegateFromSumn
                                , label =
                                    Element.text
                                        "Undelegate"
                                }
                            ]
                        )

        RegisteringAndDelegating _ _ _ _ ->
            Element.layout []
                (Element.Input.button
                    [ Element.Background.color buttonHoverColor
                    , Element.htmlAttribute (Html.Attributes.disabled True)
                    , id
                    ]
                    { onPress =
                        Just
                            NoOp
                    , label =
                        Element.text
                            "Registering and Delegating"
                    }
                )

        Delegating _ _ _ _ ->
            Element.layout []
                (Element.Input.button
                    [ Element.Background.color buttonHoverColor
                    , Element.htmlAttribute (Html.Attributes.disabled True)
                    , id
                    ]
                    { onPress =
                        Just
                            NoOp
                    , label =
                        Element.text
                            "Delegating"
                    }
                )

        Undelegating _ _ _ _ ->
            Element.layout []
                (Element.Input.button
                    [ Element.Background.color buttonHoverColor
                    , Element.htmlAttribute (Html.Attributes.disabled True)
                    , id
                    ]
                    { onPress =
                        Just
                            NoOp
                    , label =
                        Element.text
                            "Undelegating"
                    }
                )

        NullState ->
            Element.layout []
                (Element.Input.button
                    [ Element.Background.color buttonHoverColor
                    , id
                    ]
                    { onPress =
                        Just
                            NoOp
                    , label =
                        Element.text
                            "Error"
                    }
                )


buttonHoverColor : Element.Color
buttonHoverColor =
    Element.rgb255 3 233 244


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ case model of
            WalletState _ msg ->
                Sub.map ConnectW (ConnectWallet.subscriptions msg)

            _ ->
                receiveAccountStatus (\s -> ReceiveAccountStatus (Json.Decode.decodeString decodeAccount s))
        , receiveRegisterAndDelegateStatus ReceiveRegisterAndDelegateStatus
        , receiveDelegateStatus ReceiveDelegateToSumnStatus
        , receiveUndelegateStatus ReceiveUndelegateStatus
        ]


main : Program ( List String, PoolId ) Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


port getAccountStatus : () -> Cmd msg


port receiveAccountStatus : (String -> msg) -> Sub msg


port registerAndDelegateToSumn : String -> Cmd msg


port receiveRegisterAndDelegateStatus : (TransactionSuccessStatus -> msg) -> Sub msg


port delegateToSumn : String -> Cmd msg


port receiveDelegateStatus : (TransactionSuccessStatus -> msg) -> Sub msg


port undelegate : String -> Cmd msg


port receiveUndelegateStatus : (TransactionSuccessStatus -> msg) -> Sub msg
