#!/bin/bash

set -x
set -e

# Anvil Account #1
OWNER=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266

function load_snapshot {
    ANVIL_SNAPSHOT_PATH=$2 npx hardhat run --network localhost $1/../load-snapshot.ts
    echo "Snapshot loaded from $2"
}

function save_snapshot {
    cast rpc anvil_dumpState > $1
    echo "Saved Anvil snapshot to $1"
}

function deploy_and_test {
    SCRIPT_DIR=$1
    SNAPSHOT=./$SCRIPT_DIR/anvil.snapshot

    if test -f $SNAPSHOT; then
        load_snapshot $SCRIPT_DIR $SNAPSHOT
    else
        ./$SCRIPT_DIR/01-deploy-localhost.sh
        npx hardhat run --network localhost $SCRIPT_DIR/02-verify-localhost.ts

        save_snapshot $SNAPSHOT
    fi
}

cast rpc anvil_setBlockTimestampInterval 1

deploy_and_test scripts/deploys/mainnet/scripts/01-lov-sUSDe-a
deploy_and_test scripts/deploys/mainnet/scripts/02-lov-USDe-a
deploy_and_test scripts/deploys/mainnet/scripts/03-lov-weETH-a
deploy_and_test scripts/deploys/mainnet/scripts/04-lov-ezETH-a
deploy_and_test scripts/deploys/mainnet/scripts/05-lov-wstETH-a
deploy_and_test scripts/deploys/mainnet/scripts/06-lov-sUSDe-b
deploy_and_test scripts/deploys/mainnet/scripts/07-lov-USDe-b
