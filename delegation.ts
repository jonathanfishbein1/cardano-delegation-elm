import * as Lucid from 'lucid-cardano'

const
    sumnPoolId = "pool1m3gg43uhtetn4hmw79u8836dyq8qe4cex8qnn6mks5egza7n6tp",
    // register = async rewardAddress => {
    //     const transaction =
    //         await lucid
    //             .newTx()
    //             .registerStake(rewardAddress)
    //             .complete()
    //         , signedTx = await transaction
    //             .sign()
    //             .complete()
    //         , transactionHash = await signedTx
    //             .submit()
    //     return transactionHash
    // },
    delegate = async (lucid, rewardAddress) => {
        const transaction =
            await lucid
                .newTx()
                .delegateTo(rewardAddress, sumnPoolId)
                .complete()
            , signedTx = await transaction
                .sign()
                .complete()
            , transactionHash = await signedTx
                .submit()
        return transactionHash
    },
    deregister = async (lucid, rewardAddress) => {
        const transaction =
            await lucid
                .newTx()
                .deregisterStake(rewardAddress)
                .complete()
            , signedTx = await transaction
                .sign()
                .complete()
            , transactionHash = await signedTx
                .submit()
        return transactionHash
    }
    , registerAndDelegate = async (lucid, rewardAddress) => {
        const transaction =
            await lucid
                .newTx()
                .registerStake(rewardAddress)
                .delegateTo(rewardAddress, sumnPoolId)
                .complete()
            , signedTx = await transaction
                .sign()
                .complete()
            , transactionHash = await signedTx
                .submit()
        return transactionHash
    }

export {
    delegate,
    registerAndDelegate,
    deregister
}