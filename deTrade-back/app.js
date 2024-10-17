const grpc = require('@grpc/grpc-js');
const { connect, signers } = require('@hyperledger/fabric-gateway');
const crypto = require('node:crypto');
const fs = require('node:fs/promises');
// const path = require('node:path');
const { TextDecoder } = require('node:util');
const config = require('./config.js');
const path = require('node:path');

const utf8Decoder = new TextDecoder();
const assetId = `asset${String(Date.now())}`;

async function main() {
    displayInputParameters();

    // The gRPC client connection should be shared by all Gateway connections to this endpoint.
    const client = await newGrpcConnection();

    const gateway = connect({
        client,
        identity: await newIdentity(),
        signer: await newSigner(),
        // Default timeouts for different gRPC calls
        evaluateOptions: () => {
            return { deadline: Date.now() + 5000 }; // 5 seconds
        },
        endorseOptions: () => {
            return { deadline: Date.now() + 15000 }; // 15 seconds
        },
        submitOptions: () => {
            return { deadline: Date.now() + 5000 }; // 5 seconds
        },
        commitStatusOptions: () => {
            return { deadline: Date.now() + 60000 }; // 1 minute
        },
    });

    try {
        // Get a network instance representing the channel where the smart contract is deployed.
        const network = gateway.getNetwork(config.channelName);

        // Get the smart contract from the network.
        const contract = network.getContract(config.chaincodeName);

    } finally {
        gateway.close();
        client.close();
    }
}

main().catch((error) => {
    console.error('******** FAILED to run the application:', error);
    process.exitCode = 1;
});

async function newGrpcConnection() {
    const tlsRootCert = await fs.readFile(config.tlsCertPath);
    const tlsCredentials = grpc.credentials.createSsl(tlsRootCert);
    return new grpc.Client(config.peerEndpoint, tlsCredentials, {
        'grpc.ssl_target_name_override': config.peerHostAlias,
    });
}

async function newIdentity() {
    const certPath = await getFirstDirFileName(config.certDirectoryPath);
    const credentials = await fs.readFile(certPath);
    mspId = config.mspId;
    return { mspId, credentials };
}

async function getFirstDirFileName(dirPath) {
    const files = await fs.readdir(dirPath);
    const file = files[0];
    if (!file) {
        throw new Error(`No files in directory: ${dirPath}`);
    }
    return path.join(dirPath, file);
}

async function newSigner() {
    const keyPath = await getFirstDirFileName(config.keyDirectoryPath);
    const privateKeyPem = await fs.readFile(keyPath);
    const privateKey = crypto.createPrivateKey(privateKeyPem);
    return signers.newPrivateKeySigner(privateKey);
}

/**
 * This type of transaction would typically only be run once by an application the first time it was started after its
 * initial deployment. A new version of the chaincode deployed later would likely not need to run an "init" function.
 */
async function initLedger(contract) {
    console.log(
        '\n--> Submit Transaction: InitLedger, function creates the initial set of assets on the ledger'
    );

    await contract.submitTransaction('InitLedger');

    console.log('*** Transaction committed successfully');
}


async function createUser(contract, ID){
    console.log(
        '\n--> Submit Transaction: CreateUser, function creates new user on the ledger'
    );

    await contract.submitTransaction('CreateUser', ID, '0');

    console.log('*** Transaction committed successfully');
}


async function getUser(contract, ID){
    console.log(
        '\n--> Evaluate Transaction: GetUser, function returns a user'
    );

    const resultBytes = await contract.evaluateTransaction('GetUser', ID);

    const resultJson = utf8Decoder.decode(resultBytes);
    const result = JSON.parse(resultJson);
    console.log('*** Result:', result);
}

/*
func mint(contract *client.Contract, ID string) {
	fmt.Println("\n--> Submit Transaction: Mint")

	_, err := contract.SubmitTransaction("Mint", ID, "100")
	if err != nil {
		panic(fmt.Errorf("failed to evaluate transaction: %w", err))
	}

	fmt.Printf("*** Transaction committed successfully\n")
}
*/
async function mint(contract, ID, value){
    console.log(
        '\n--> Submit Transaction: Mint, function mints new asset on the ledger'
    );

    await contract.submitTransaction('Mint', ID, value);

    console.log('*** Transaction committed successfully');
}


async function burn(contract, ID, value){
    console.log(
        '\n--> Submit Transaction: Burn, function burns asset on the ledger'
    );

    await contract.submitTransaction('Burn', ID, value);

    console.log('*** Transaction committed successfully');
}


async function createDataset(contract, title, description, hash, ipfsAddress, n_subset, owner, price, tags){
    console.log(
        '\n--> Submit Transaction: CreateDataset, creates new dataset on the ledger'
    );
    await contract.submitTransaction('CreateDataset', title, description, hash, ipfsAddress, n_subset, owner, price, tags);

    console.log('*** Transaction committed successfully');
}

async function createOrder(contract, buyer, datasetID, payHash){
    console.log(
        '\n--> Submit Transaction: CreateOrder, creates new order on the ledger'
    );

    await contract.submitTransaction('CreateOrder', buyer, datasetID, payHash);

    console.log('*** Transaction committed successfully');
}

async function getDataset(contract, datasetID){
    console.log(
        '\n--> Evaluate Transaction: GetDataset, function returns a dataset'
    );

    const resultBytes = await contract.evaluateTransaction('GetDataset', datasetID);

    const resultJson = utf8Decoder.decode(resultBytes);
    const result = JSON.parse(resultJson);
    console.log('*** Result:', result);
}

async function getOrder(contract, orderID){
    console.log(
        '\n--> Evaluate Transaction: GetOrder, function returns a order'
    );

    const resultBytes = await contract.evaluateTransaction('GetOrder', orderID);

    const resultJson = utf8Decoder.decode(resultBytes);
    const result = JSON.parse(resultJson);
    console.log('*** Result:', result);
}

async function getDatasetList(contract) {
	console.log(
		'\n--> Evaluate Transaction: GetDatasetList, function returns a dataset list'
	);

	const resultBytes = await contract.evaluateTransaction('GetDatasetList');

	const resultJson = utf8Decoder.decode(resultBytes);
	const result = JSON.parse(resultJson);
	console.log('*** Result:', result);
}
async function getOrderList(contract) {
    console.log(
        '\n--> Evaluate Transaction: GetOrderList, function returns a order list'
    );

    const resultBytes = await contract.evaluateTransaction('GetOrderList');

    const resultJson = utf8Decoder.decode(resultBytes);
    const result = JSON.parse(resultJson);
    console.log('*** Result:', result);
}

async function handleOrder(contract, orderID, n, payword){
    console.log(
        '\n--> Submit Transaction: HandleOrder, function handles order on the ledger'
    );

    await contract.submitTransaction('HandleOrder', orderID, n, payword);

    console.log('*** Transaction committed successfully');
}






/**
 * displayInputParameters() will print the global scope parameters used by the main driver routine.
 */
function displayInputParameters() {
    console.log(`channelName:       ${config.channelName}`);
    console.log(`chaincodeName:     ${config.chaincodeName}`);
    console.log(`mspId:             ${config.mspId}`);
    console.log(`cryptoPath:        ${config.cryptoPath}`);
    console.log(`keyDirectoryPath:  ${config.keyDirectoryPath}`);
    console.log(`certDirectoryPath: ${config.certDirectoryPath}`);
    console.log(`tlsCertPath:       ${config.tlsCertPath}`);
    console.log(`peerEndpoint:      ${config.peerEndpoint}`);
    console.log(`peerHostAlias:     ${config.peerHostAlias}`);
}
