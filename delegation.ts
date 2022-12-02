import * as Lucid from 'lucid-cardano'
const
    register = async (lucid: Lucid.Lucid, rewardAddress) => {
        const transaction =
            await lucid
                .newTx()
                .registerStake(rewardAddress)
                .complete()
            , signedTx = await transaction
                .sign()
                .complete()
            , transactionHash = await signedTx
                .submit()
        return transactionHash
    },
    delegate = async (lucid: Lucid.Lucid, rewardAddress, poolId) => {
        const transaction =
            await lucid
                .newTx()
                .delegateTo(rewardAddress, poolId)
                .complete()
            , signedTx = await transaction
                .sign()
                .complete()
            , transactionHash = await signedTx
                .submit()
        return transactionHash
    },
    deregister = async (lucid: Lucid.Lucid, rewardAddress) => {
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
    , registerAndDelegate = async (lucid: Lucid.Lucid, rewardAddress, poolId) => {
        const registerTransaction =
            await lucid
                .newTx()
                .registerStake(rewardAddress)
            , delegateTransaction =
                await lucid
                    .newTx()
                    .delegateTo(rewardAddress, poolId)
            , transaction =
                await delegateTransaction.compose(registerTransaction).complete()
            , signedTx = await transaction
                .sign()
                .complete()
            , transactionHash = await signedTx
                .submit()
        return transactionHash
    }

export {
    register,
    delegate,
    registerAndDelegate,
    deregister
}