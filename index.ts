import * as Lucid from 'lucid-cardano'
import * as Wallet from '../connect-cardano-wallet-elm/wallet'
var { Elm } = require('./src/Delegation.elm')
import * as Delegation from './delegation'

const
    sumnPoolId = "pool1m3gg43uhtetn4hmw79u8836dyq8qe4cex8qnn6mks5egza7n6tp",
    bk = "mainnetU8uxziYphJfG9PTWWplZD2lEHMXbJHCX"
    , blockfrostApi = 'https://cardano-mainnet.blockfrost.io/api/v0'
    , blockfrostClient = new Lucid.Blockfrost(blockfrostApi, bk)
    , lucid = await Lucid.Lucid.new(blockfrostClient,
        'Mainnet')

var app = Elm.Delegation.init({
    flags: [(await Wallet.walletsEnabled()), sumnPoolId],
    node: document.getElementById("elm-app-is-loaded-here")
})

app.ports.connectWallet.subscribe(async supportedWallet => {
    try {
        const wallet = await Wallet.getWalletApi(supportedWallet!) as any
        lucid.selectWallet(wallet)
        console.log(wallet)
        app.ports.receiveWalletConnection.send(supportedWallet)
    }
    catch (err) {
        app.ports.receiveWalletConnection.send('err')
    }
})

app.ports.getAccountStatus.subscribe(async () => {
    console.log('here')
    const rewardAddress = await lucid.wallet.rewardAddress()
        , utils = new Lucid.Utils(lucid)
        , { address: { bech32 } } = utils.getAddressDetails(rewardAddress!)
        , account = await fetch(`${blockfrostApi}/accounts/${(bech32)}/`
            , { headers: { project_id: bk } })
            .then(res => res.json())
    console.log(account)
    app.ports.receiveAccountStatus.send(JSON.stringify(account))
})


app.ports.registerAndDelegateToSumn.subscribe(async rewardAddress => {
    try {
        console.log('here')
        const txHash = await Delegation.registerAndDelegate(lucid, rewardAddress, sumnPoolId)
        console.log(txHash)
        txHash ? app.ports.receiveRegisterAndDelegateStatus.send(true)
            : app.ports.receiveRegisterAndDelegateStatus.send(false)
    }
    catch (e) {
        console.log(e)
        app.ports.receiveRegisterAndDelegateStatus.send(false)
    }
})

app.ports.delegateToSumn.subscribe(async rewardAddress => {
    try {
        const txHash = await Delegation.delegate(lucid, rewardAddress, sumnPoolId)
        txHash ? app.ports.receiveDelegateToSumnStatus.send(true)
            : app.ports.receiveDelegateToSumnStatus.send(false)
    }
    catch (e) {
        app.ports.receiveDelegateToSumnStatus.send(false)
    }
})