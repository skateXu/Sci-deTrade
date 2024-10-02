/*
SPDX-License-Identifier: Apache-2.0
*/

package main

import (
	"log"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"chaincode-go/chaincode"
)

func main() {
	tokenChaincode, err := contractapi.NewChaincode(&chaincode.SmartContract{})
	if err != nil {
		log.Panicf("Error creating data trading chaincode: %v", err)
	}

	if err := tokenChaincode.Start(); err != nil {
		log.Panicf("Error starting data trading chaincode: %v", err)
	}
}
