package main

import (
	"bytes"
	"crypto/x509"
	"encoding/json"
	"fmt"
	"os"
	"path"
	"time"

	"github.com/hyperledger/fabric-gateway/pkg/client"
	"github.com/hyperledger/fabric-gateway/pkg/identity"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
)

// test datatrading-chaincode on tetest network
const (
	mspID        = "Org1MSP"
	cryptoPath   = "../../deTrade-network/organizations/peerOrganizations/org1.example.com"
	certPath     = cryptoPath + "/users/User1@org1.example.com/msp/signcerts/cert.pem"
	keyPath      = cryptoPath + "/users/User1@org1.example.com/msp/keystore/"
	tlsCertPath  = cryptoPath + "/peers/peer0.org1.example.com/tls/ca.crt"
	peerEndpoint = "localhost:7051"
	gatewayPeer  = "peer0.org1.example.com"
)

var now = time.Now()
var assetId = fmt.Sprintf("asset%d", now.Unix()*1e3+int64(now.Nanosecond())/1e6)

func main() {
	// The gRPC client connection should be shared by all Gateway connections to this endpoint
	clientConnection := newGrpcConnection()
	defer clientConnection.Close()

	id := newIdentity()
	sign := newSign()

	// Create a Gateway connection for a specific client identity
	gw, err := client.Connect(
		id,
		client.WithSign(sign),
		client.WithClientConnection(clientConnection),
		// Default timeouts for different gRPC calls
		client.WithEvaluateTimeout(5*time.Second),
		client.WithEndorseTimeout(15*time.Second),
		client.WithSubmitTimeout(5*time.Second),
		client.WithCommitStatusTimeout(1*time.Minute),
	)
	if err != nil {
		panic(err)
	}
	defer gw.Close()
	// Override default values for chaincode and channel name as they may differ in testing contexts.
	chaincodeName := "datatrading"
	if ccname := os.Getenv("CHAINCODE_NAME"); ccname != "" {
		chaincodeName = ccname
	}

	channelName := "mychannel"
	if cname := os.Getenv("CHANNEL_NAME"); cname != "" {
		channelName = cname
	}

	network := gw.GetNetwork(channelName)
	contract := network.GetContract(chaincodeName)

	initLedger(contract)
	createUser(contract, "u1")
	createUser(contract, "u2")
	mint(contract, "u1")
	mint(contract, "u2")
	getUser(contract, "u1")
	getUser(contract, "u2")
	createDataset(contract, "u1")
	getDataset(contract, "dataset1")
	createOrder(contract, "u2")
	getOrder(contract, "order1")
	getDatasetList(contract)
	getOrderList(contract)
	getUser(contract, "u1")
	getUser(contract, "u2")
	getUser(contract, "contract")
	handleOrder(contract, "order1", "1", "1234")
	getUser(contract, "u1")
	getUser(contract, "u2")
	getUser(contract, "contract")
	getOrder(contract, "order1")
	// createOrder(contract)
	// getUser(contract,"u1")
	// getUser(contract,"u2")
	// getOrderList(contract)

}

// newGrpcConnection creates a gRPC connection to the Gateway server.
func newGrpcConnection() *grpc.ClientConn {
	certificate, err := loadCertificate(tlsCertPath)
	if err != nil {
		panic(err)
	}

	certPool := x509.NewCertPool()
	certPool.AddCert(certificate)
	transportCredentials := credentials.NewClientTLSFromCert(certPool, gatewayPeer)

	connection, err := grpc.Dial(peerEndpoint, grpc.WithTransportCredentials(transportCredentials))
	if err != nil {
		panic(fmt.Errorf("failed to create gRPC connection: %w", err))
	}

	return connection
}

// newIdentity creates a client identity for this Gateway connection using an X.509 certificate.
func newIdentity() *identity.X509Identity {
	certificate, err := loadCertificate(certPath)
	if err != nil {
		panic(err)
	}

	id, err := identity.NewX509Identity(mspID, certificate)
	if err != nil {
		panic(err)
	}

	return id
}

func loadCertificate(filename string) (*x509.Certificate, error) {
	certificatePEM, err := os.ReadFile(filename)
	if err != nil {
		return nil, fmt.Errorf("failed to read certificate file: %w", err)
	}
	return identity.CertificateFromPEM(certificatePEM)
}

// newSign creates a function that generates a digital signature from a message digest using a private key.
func newSign() identity.Sign {
	files, err := os.ReadDir(keyPath)
	if err != nil {
		panic(fmt.Errorf("failed to read private key directory: %w", err))
	}
	privateKeyPEM, err := os.ReadFile(path.Join(keyPath, files[0].Name()))

	if err != nil {
		panic(fmt.Errorf("failed to read private key file: %w", err))
	}

	privateKey, err := identity.PrivateKeyFromPEM(privateKeyPEM)
	if err != nil {
		panic(err)
	}

	sign, err := identity.NewPrivateKeySign(privateKey)
	if err != nil {
		panic(err)
	}

	return sign
}

// This type of transaction would typically only be run once by an application the first time it was started after its
// initial deployment. A new version of the chaincode deployed later would likely not need to run an "init" function.
func initLedger(contract *client.Contract) {
	fmt.Printf("\n--> Submit Transaction: InitLedger, function creates the initial lists on the ledger \n")

	_, err := contract.SubmitTransaction("InitLedger")
	if err != nil {
		panic(fmt.Errorf("failed to submit transaction: %w", err))
	}

	fmt.Printf("*** Transaction committed successfully\n")
}

// create a new user

func createUser(contract *client.Contract, ID string) {
	fmt.Println("\n--> Submit Transaction: CreateUser")
	_, err := contract.SubmitTransaction("CreateUser", ID, "0")
	if err != nil {
		panic(fmt.Errorf("failed to evaluate transaction: %w", err))
	}
	fmt.Printf("*** Transaction committed successfully\n")
}

// Evaluate GetUser
func getUser(contract *client.Contract, ID string) {
	fmt.Println("\n--> Evaluate Transaction: GetUser, function returns a user")
	evaluateResult, err := contract.EvaluateTransaction("GetUser", ID)
	if err != nil {
		panic(fmt.Errorf("failed to evaluate transaction: %w", err))
	}
	result := formatJSON(evaluateResult)
	fmt.Printf("*** Result:%s\n", result)
}

// Evaluate Mint.
func mint(contract *client.Contract, ID string) {
	fmt.Println("\n--> Submit Transaction: Mint")

	_, err := contract.SubmitTransaction("Mint", ID, "100")
	if err != nil {
		panic(fmt.Errorf("failed to evaluate transaction: %w", err))
	}

	fmt.Printf("*** Transaction committed successfully\n")
}

// Evaluate Burn.
func burn(contract *client.Contract, ID string) {
	fmt.Println("\n--> Submit Transaction: Burn")

	_, err := contract.SubmitTransaction("Burn", ID, "100")
	if err != nil {
		panic(fmt.Errorf("failed to evaluate transaction: %w", err))
	}

	fmt.Printf("*** Transaction committed successfully\n")
}

// Create a new dataset
func createDataset(contract *client.Contract, ID string) {
	fmt.Println("\n--> Submit Transaction: CreateDataset")
	tags := []string{"1", "2", "3"}
	jsonBytes, _ := json.Marshal(tags)
	_, err := contract.SubmitTransaction("CreateDataset", "牛子数据", "description", "hash", "ipfsAddress", "2", ID, "100", string(jsonBytes))
	if err != nil {
		panic(fmt.Errorf("failed to evaluate transaction: %w", err))
	}
	fmt.Printf("*** Transaction committed successfully\n")
}

// Create a new order
func createOrder(contract *client.Contract, ID string) {
	fmt.Println("\n--> Submit Transaction: CreateOrder")
	_, err := contract.SubmitTransaction("CreateOrder", ID, "dataset1", "hash")
	if err != nil {
		panic(fmt.Errorf("failed to evaluate transaction: %w", err))
	}
	fmt.Printf("*** Transaction committed successfully\n")
}

// Evaluate GetDataset.
func getDataset(contract *client.Contract, datasetID string) {
	fmt.Println("\n--> Evaluate Transaction: GetDataset, function returns a dataset")
	evaluateResult, err := contract.EvaluateTransaction("GetDataset", datasetID)
	if err != nil {
		panic(fmt.Errorf("failed to evaluate transaction: %w", err))
	}
	result := formatJSON(evaluateResult)
	fmt.Printf("*** Result:%s\n", result)
}

// Evaluate GetOrder.
func getOrder(contract *client.Contract, orderID string) {
	fmt.Println("\n--> Evaluate Transaction: GetOrder, function returns a order")
	evaluateResult, err := contract.EvaluateTransaction("GetOrder", orderID)
	if err != nil {
		panic(fmt.Errorf("failed to evaluate transaction: %w", err))
	}
	result := formatJSON(evaluateResult)
	fmt.Printf("*** Result:%s\n", result)
}

// Evaluate GetDatasetList.
func getDatasetList(contract *client.Contract) {
	fmt.Println("\n--> Evaluate Transaction: GetDatasetList, function returns a dataset list")
	evaluateResult, err := contract.EvaluateTransaction("GetDatasetList")
	if err != nil {
		panic(fmt.Errorf("failed to evaluate transaction: %w", err))
	}
	result := formatJSON(evaluateResult)
	fmt.Printf("*** Result:%s\n", result)
}

// Evalute GetOrderList.
func getOrderList(contract *client.Contract) {
	fmt.Println("\n--> Evaluate Transaction: GetOrderList, function returns a order list")
	evaluateResult, err := contract.EvaluateTransaction("GetOrderList")
	if err != nil {
		panic(fmt.Errorf("failed to evaluate transaction: %w", err))
	}
	result := formatJSON(evaluateResult)
	fmt.Printf("*** Result:%s\n", result)
}

// Handle Order
func handleOrder(contract *client.Contract, orderID string, n string, payword string) {
	fmt.Println("\n--> Submit Transaction: HandleOrder")
	_, err := contract.SubmitTransaction("HandleOrder", orderID, n, payword)
	if err != nil {
		panic(fmt.Errorf("failed to evaluate transaction: %w", err))
	}
	fmt.Printf("***Transaction committed successfully\n")
}

// Format JSON data
func formatJSON(data []byte) string {
	var prettyJSON bytes.Buffer
	if err := json.Indent(&prettyJSON, data, "", "  "); err != nil {
		panic(fmt.Errorf("failed to parse JSON: %w", err))
	}
	return prettyJSON.String()
}

// Submit transaction asynchronously, blocking until the transaction has been sent to the orderer, and allowing
// this thread to process the chaincode response (e.g. update a UI) without waiting for the commit notification
// func transferAssetAsync(contract *client.Contract) {
// 	fmt.Printf("\n--> Async Submit Transaction: TransferAsset, updates existing asset owner")

// 	submitResult, commit, err := contract.SubmitAsync("TransferAsset", client.WithArguments(assetId, "Mark"))
// 	if err != nil {
// 		panic(fmt.Errorf("failed to submit transaction asynchronously: %w", err))
// 	}

// 	fmt.Printf("\n*** Successfully submitted transaction to transfer ownership from %s to Mark. \n", string(submitResult))
// 	fmt.Println("*** Waiting for transaction commit.")

// 	if commitStatus, err := commit.Status(); err != nil {
// 		panic(fmt.Errorf("failed to get commit status: %w", err))
// 	} else if !commitStatus.Successful {
// 		panic(fmt.Errorf("transaction %s failed to commit with status: %d", commitStatus.TransactionID, int32(commitStatus.Code)))
// 	}

// 	fmt.Printf("*** Transaction committed successfully\n")
// }
