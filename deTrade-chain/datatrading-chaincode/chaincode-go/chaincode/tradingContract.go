package chaincode

import (
	// "bytes"
	// "crypto/sha256"
	"encoding/json"
	// "errors"
	"fmt"
	"log"
	"strconv"
	"time"

	"github.com/golang/protobuf/ptypes"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type SmartContract struct {
	contractapi.Contract
}

// Insert struct field in alphabetic order => to achieve determinism across languages
// golang keeps the order when marshal to json but doesn't order automatically

/*
DatasetList stores all IDs of the dataset
Use this to search all dataset
*/
type DatasetList struct {
	DatasetIDs []string `json:"DatasetIDs"`
	DLID       string   `json:"DLID"`
	Next       int      `json:"Next"`
}

/*
OrderList stores all IDs of the order
Use this to search all orders
Next: current number of orders, new order, Next++
*/
type OrderList struct {
	Next     int      `json:"Next"`
	OLID     string   `json:"OLID"`
	OrderIDs []string `json:"OrderIDs"`
}

// UserList stores all IDs of the user
type UserList struct {
	ULID    string   `json:"ULID"`
	UserIDs []string `json:"UserIDs"`
}

/*
Dataset stores details about a dataset
Hash: verify the encrypted data
N_subset: number of subsets in the dataset
Owner: the owner of the dataset
Price: price of the dataset
Tags: tags of the dataset which used to verify the keys of each subset
Describtion: description of the dataset
IPFSAddress: IPFS address of the dataset
*/
type Dataset struct {
	DatasetID   string   `json:"DatasetID"`
	Describtion string   `json:"Description"`
	Hash        string   `json:"Hash"`
	IpfsAddress string   `json:"IpfsAddress"`
	N_subset    int      `json:"N_subset"`
	Owner       string   `json:"Owner"`
	Price       int      `json:"Price"`
	Tags        []string `json:"Tags"`
	Title       string   `json:"Title"`
}

/*
Order stores details about a order
Buyer: the buyer of the dataset
DatasetID: the ID of the dataset
OrderID: the ID of the order
PayHash: submit the seed to get paid
EndTime: the end time of the order
*/
type Order struct {
	Buyer     string    `json:"Buyer"`
	DatasetID string    `json:"DatasetID"`
	EndTime   time.Time `json:"EndTime"`
	OrderID   string    `json:"OrderID"`
	PayHash   string    `json:"PayHash"`
}

/*
User stores details about a user
DataSets: the IDs of the datasets that the user owns
Ords: the IDs of the orders that the user has made
UID: the ID of the user
Value: the money of the user
*/
type User struct {
	BuyOrderIDs  []string `json:"BuyOrderIDs"`
	DatasetIDs   []string `json:"DatasetIDs"`
	Nonce        int      `json:"Nonce"`
	SellOrderIDs []string `json:"SellOrderIDs"`
	UID          string   `json:"UID"`
	Value        int      `json:"Value"`
}

func (s *SmartContract) InitLedger(ctx contractapi.TransactionContextInterface) error {
	// InitLedger adds basic data structures to the ledger (three lists)

	// TODO only admin can do this

	datasetList := DatasetList{
		DatasetIDs: []string{},
		DLID:       "DatasetList",
		Next:       0,
	}
	datasetListJSON, err := json.Marshal(datasetList)
	if err != nil {
		return err
	}
	err = ctx.GetStub().PutState("DatasetList", datasetListJSON)
	if err != nil {
		return fmt.Errorf("failed to put to world state. %v", err)
	}
	orderList := OrderList{
		Next:     0,
		OLID:     "OrderList",
		OrderIDs: []string{},
	}
	orderListJSON, err := json.Marshal(orderList)
	if err != nil {
		return err
	}
	err = ctx.GetStub().PutState("OrderList", orderListJSON)
	if err != nil {
		return fmt.Errorf("failed to put to world state. %v", err)
	}
	userList := UserList{
		ULID:    "UserList",
		UserIDs: []string{},
	}
	userList.UserIDs = append(userList.UserIDs, "contract")
	userListJSON, err := json.Marshal(userList)
	if err != nil {
		return err
	}
	err = ctx.GetStub().PutState("UserList", userListJSON)
	if err != nil {
		return fmt.Errorf("failed to put to world state. %v", err)
	}
	user := User{
		BuyOrderIDs:  []string{},
		DatasetIDs:   []string{},
		SellOrderIDs: []string{},
		UID:          "contract",
		Value:        0,
	}
	userJSON, err := json.Marshal(user)
	if err != nil {
		return err
	}
	err = ctx.GetStub().PutState("contract", userJSON)
	if err != nil {
		return fmt.Errorf("failed to put to world state. %v", err)
	}

	return nil
}

func (s *SmartContract) CreateDataset(ctx contractapi.TransactionContextInterface, title string, description string, hash string, ipfsAddress string, n_subset int, owner string, price int, tags []string) error {
	/*
		CreateDataset creates a new dataset
		add to DatasetList
		update user's dataset
	*/
	datasetListAsBytes, err := ctx.GetStub().GetState("DatasetList")
	if err != nil {
		return fmt.Errorf("failed to read from world state. %v", err)
	}
	var datasetList DatasetList
	err = json.Unmarshal(datasetListAsBytes, &datasetList)
	if err != nil {
		return err
	}

	dataset := Dataset{
		DatasetID:   "dataset" + strconv.Itoa(datasetList.Next+1),
		Describtion: description,
		Hash:        hash,
		IpfsAddress: ipfsAddress,
		N_subset:    n_subset,
		Owner:       owner,
		Price:       price,
		Tags:        tags,
		Title:       title,
	}
	datasetJSON, err := json.Marshal(dataset)
	if err != nil {
		return err
	}
	err = ctx.GetStub().PutState(dataset.DatasetID, datasetJSON)
	if err != nil {
		return fmt.Errorf("failed to put to world state. %v", err)
	}
	datasetList.DatasetIDs = append(datasetList.DatasetIDs, dataset.DatasetID)
	datasetList.Next += 1
	datasetListJSON, err := json.Marshal(datasetList)
	if err != nil {
		return err
	}
	err = ctx.GetStub().PutState("DatasetList", datasetListJSON)
	if err != nil {
		return fmt.Errorf("failed to put to world state. %v", err)
	}

	userAsBytes, err := ctx.GetStub().GetState(owner)
	if err != nil {
		return fmt.Errorf("failed to read from world state. %v", err)
	}
	var user User
	err = json.Unmarshal(userAsBytes, &user)
	if err != nil {
		return err
	}
	user.DatasetIDs = append(user.DatasetIDs, dataset.DatasetID)
	userJSON, err := json.Marshal(user)
	if err != nil {
		return err
	}
	err = ctx.GetStub().PutState(owner, userJSON)
	if err != nil {
		return fmt.Errorf("failed to put to world state. %v", err)
	}
	return nil
}

func (s *SmartContract) CreateOrder(ctx contractapi.TransactionContextInterface, buyer string, datasetID string, payHash string) error {
	/*
		CreateOrder creates a new order
		add to OrderList
		update user's order
	*/

	var dataset Dataset
	datasetAsBytes, err := ctx.GetStub().GetState(datasetID)
	if err != nil {
		return fmt.Errorf("failed to read from world state. %v", err)
	}
	err = json.Unmarshal(datasetAsBytes, &dataset)
	if err != nil {
		return err
	}
	// read OrderList
	orderListAsBytes, err := ctx.GetStub().GetState("OrderList")
	if err != nil {
		return fmt.Errorf("failed to read from world state. %v", err)
	}
	var orderList OrderList
	err = json.Unmarshal(orderListAsBytes, &orderList)
	if err != nil {
		return err
	}
	// add order
	orderList.OrderIDs = append(orderList.OrderIDs, strconv.Itoa(orderList.Next+1))
	orderList.Next += 1
	orderListJSON, err := json.Marshal(orderList)
	if err != nil {
		return err
	}
	// write to world state
	err = ctx.GetStub().PutState("OrderList", orderListJSON)
	if err != nil {
		return fmt.Errorf("failed to put to world state. %v", err)
	}

	txTimestamp, err := ctx.GetStub().GetTxTimestamp()
	timestamp, err := ptypes.Timestamp(txTimestamp)
	duration := time.Hour
	timestamp = timestamp.Add(duration)
	if err != nil {
		return fmt.Errorf("failed to create timestamp for receipt: %v", err)
	}
	order := Order{
		Buyer:     buyer,
		DatasetID: datasetID,
		OrderID:   "order" + strconv.Itoa(orderList.Next),
		PayHash:   payHash,
		EndTime:   timestamp,
	}
	orderJSON, err := json.Marshal(order)
	if err != nil {
		return err
	}
	err = ctx.GetStub().PutState(order.OrderID, orderJSON)
	if err != nil {
		return fmt.Errorf("failed to put to world state. %v", err)
	}

	// add buyer order
	userAsBytes, err := ctx.GetStub().GetState(buyer)
	if err != nil {
		return fmt.Errorf("failed to read from world state. %v", err)
	}
	var user User
	err = json.Unmarshal(userAsBytes, &user)
	if err != nil {
		return err
	}
	user.BuyOrderIDs = append(user.BuyOrderIDs, order.OrderID)

	if user.Value < dataset.Price {
		return fmt.Errorf("value is greater than buyer.Value")
	}
	user.Value, err = sub(user.Value, dataset.Price)
	if err != nil {
		return err
	}
	toAsBytes, err := ctx.GetStub().GetState("contract")
	if err != nil {
		return fmt.Errorf("failed to read from world state. %v", err)
	}
	var toUser User
	err = json.Unmarshal(toAsBytes, &toUser)
	if err != nil {
		return err
	}
	toUser.Value, err = add(toUser.Value, dataset.Price)
	if err != nil {
		return err
	}
	userJSON, err := json.Marshal(user)
	if err != nil {
		return err
	}
	err = ctx.GetStub().PutState(buyer, userJSON)
	if err != nil {
		return fmt.Errorf("failed to put to world state. %v", err)
	}
	toUserJSON, err := json.Marshal(toUser)
	if err != nil {
		return err
	}
	err = ctx.GetStub().PutState("contract", toUserJSON)
	if err != nil {
		return fmt.Errorf("failed to put to world state. %v", err)
	}
	log.Printf("transfer successful")

	//add seller order
	userAsBytes, err = ctx.GetStub().GetState(dataset.Owner)
	if err != nil {
		return fmt.Errorf("failed to read from world state. %v", err)
	}
	var seller User
	err = json.Unmarshal(userAsBytes, &seller)
	if err != nil {
		return err
	}
	seller.SellOrderIDs = append(seller.SellOrderIDs, order.OrderID)
	sellerJSON, err := json.Marshal(seller)
	if err != nil {
		return err
	}
	err = ctx.GetStub().PutState(dataset.Owner, sellerJSON)
	if err != nil {
		return fmt.Errorf("failed to put to world state. %v", err)
	}
	return nil
}

func (s *SmartContract) CreateUser(ctx contractapi.TransactionContextInterface, uID string, value int) error {
	/*
		CreateUser creates a new user
		add to UserList
	*/
	userListAsBytes, err := ctx.GetStub().GetState("UserList")
	if err != nil {
		return fmt.Errorf("failed to read from world state. %v", err)
	}
	var userList UserList
	err = json.Unmarshal(userListAsBytes, &userList)
	if err != nil {
		return err
	}
	// if uID in UserIDs
	// if contains(userList.UserIDs, uID) {
	// 	return fmt.Errorf("user already exists: %s", uID)
	// }
	userList.UserIDs = append(userList.UserIDs, uID)
	userListJSON, err := json.Marshal(userList)
	if err != nil {
		return err
	}
	err = ctx.GetStub().PutState("UserList", userListJSON)
	if err != nil {
		return fmt.Errorf("failed to put to world state. %v", err)
	}
	user := User{
		BuyOrderIDs:  []string{},
		DatasetIDs:   []string{},
		Nonce:        0,
		SellOrderIDs: []string{},
		UID:          uID,
		Value:        0,
	}
	userJSON, err := json.Marshal(user)
	if err != nil {
		return err
	}
	err = ctx.GetStub().PutState(uID, userJSON)
	if err != nil {
		return fmt.Errorf("failed to put to world state. %v", err)
	}
	return nil
}

func (s *SmartContract) GetDataset(ctx contractapi.TransactionContextInterface, datasetID string) (*Dataset, error) {
	/*
		GetDataset returns the dataset with given ID
	*/
	datasetAsBytes, err := ctx.GetStub().GetState(datasetID)
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state. %v", err)
	}
	if datasetAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", datasetID)
	}
	dataset := new(Dataset)
	err = json.Unmarshal(datasetAsBytes, dataset)
	if err != nil {
		return nil, err
	}
	return dataset, nil
}

func (s *SmartContract) GetOrder(ctx contractapi.TransactionContextInterface, orderID string) (*Order, error) {
	/*
		GetOrder returns the order with given ID
	*/
	orderAsBytes, err := ctx.GetStub().GetState(orderID)
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state. %v", err)
	}
	if orderAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", orderID)
	}
	order := new(Order)
	err = json.Unmarshal(orderAsBytes, order)
	if err != nil {
		return nil, err
	}
	return order, nil
}

func (s *SmartContract) GetUser(ctx contractapi.TransactionContextInterface, uID string) (*User, error) {
	/*
		GetUser returns the user with given ID
	*/
	userAsBytes, err := ctx.GetStub().GetState(uID)
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state. %v", err)
	}
	if userAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", uID)
	}
	user := new(User)
	err = json.Unmarshal(userAsBytes, user)
	if err != nil {
		return nil, err
	}
	return user, nil
}

func (s *SmartContract) GetDatasetList(ctx contractapi.TransactionContextInterface) (*DatasetList, error) {
	/*
		GetDatasetList returns the dataset list
	*/
	datasetListAsBytes, err := ctx.GetStub().GetState("DatasetList")
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state. %v", err)
	}
	var datasetList DatasetList
	err = json.Unmarshal(datasetListAsBytes, &datasetList)
	if err != nil {
		return nil, err
	}
	return &datasetList, nil
}

func (s *SmartContract) GetOrderList(ctx contractapi.TransactionContextInterface) (*OrderList, error) {
	/*
		GetOrderList returns the order list
	*/
	orderListAsBytes, err := ctx.GetStub().GetState("OrderList")
	if err != nil {
		return nil, fmt.Errorf("failed to read from world state. %v", err)
	}
	var orderList OrderList
	err = json.Unmarshal(orderListAsBytes, &orderList)
	if err != nil {
		return nil, err
	}
	return &orderList, nil
}

func (s *SmartContract) HandleOrder(ctx contractapi.TransactionContextInterface, orderID string, n int, payword string) error {
	/*
		HandleOrder handles the order
		Only user can invoke this function
	*/
	// get order
	orderAsBytes, err := ctx.GetStub().GetState(orderID)
	if err != nil {
		return fmt.Errorf("failed to read from world state. %v", err)
	}
	if orderAsBytes == nil {
		return fmt.Errorf("%s does not exist", orderID)
	}
	var order Order
	err = json.Unmarshal(orderAsBytes, &order)
	if err != nil {
		return err
	}
	txTimestamp, err := ctx.GetStub().GetTxTimestamp()
	timestamp, err := ptypes.Timestamp(txTimestamp)
	if err != nil {
		return err
	}

	// get dataset
	datasetAsBytes, err := ctx.GetStub().GetState(order.DatasetID)
	if err != nil {
		return fmt.Errorf("failed to read from world state. %v", err)
	}
	if datasetAsBytes == nil {
		return fmt.Errorf("%s does not exist", order.DatasetID)
	}
	var dataset Dataset
	err = json.Unmarshal(datasetAsBytes, &dataset)
	if err != nil {
		return err
	}
	// get buyer
	buyerAsBytes, err := ctx.GetStub().GetState(order.Buyer)
	if err != nil {
		return fmt.Errorf("failed to read from world state. %v", err)
	}
	if buyerAsBytes == nil {
		return fmt.Errorf("%s does not exist", order.Buyer)
	}
	var buyer User
	err = json.Unmarshal(buyerAsBytes, &buyer)
	if err != nil {
		return err
	}

	// get seller
	sellerAsBytes, err := ctx.GetStub().GetState(dataset.Owner)
	if err != nil {
		return fmt.Errorf("failed to read from world state. %v", err)
	}
	if sellerAsBytes == nil {
		return fmt.Errorf("%s does not exist", dataset.Owner)
	}
	var seller User
	err = json.Unmarshal(sellerAsBytes, &seller)
	if err != nil {
		return err
	}

	// get contract
	contractAsBytes, err := ctx.GetStub().GetState("contract")
	if err != nil {
		return fmt.Errorf("failed to read from world state. %v", err)
	}
	var contract User
	err = json.Unmarshal(contractAsBytes, &contract)
	if err != nil {
		return err
	}

	// check if order is expired
	if timestamp.After(order.EndTime) && !order.EndTime.IsZero() {
		contract.Value, err = sub(contract.Value, dataset.Price)
		if err != nil {
			return err
		}
		buyer.Value, err = add(buyer.Value, dataset.Price)
		if err != nil {
			return err
		}
		order.EndTime = time.Time{}
		// write buyer
		buyerJSON, err := json.Marshal(buyer)
		if err != nil {
			return err
		}
		err = ctx.GetStub().PutState(order.Buyer, buyerJSON)
		if err != nil {
			return fmt.Errorf("failed to put to world state. %v", err)
		}
		//write contract
		contractJSON, err := json.Marshal(contract)
		if err != nil {
			return err
		}
		err = ctx.GetStub().PutState("contract", contractJSON)
		if err != nil {
			return fmt.Errorf("failed to put to world state. %v", err)
		}
		// write order
		orderJSON, err := json.Marshal(order)
		if err != nil {
			return err
		}
		err = ctx.GetStub().PutState(orderID, orderJSON)
		if err != nil {
			return fmt.Errorf("failed to put to world state. %v", err)
		}
		return nil
	} else {
		// if hash(payword)==hash
		contract.Value, err = sub(contract.Value, dataset.Price)
		if err != nil {
			return err
		}
		buyer.Value, err = add(buyer.Value, n*dataset.Price/dataset.N_subset)
		if err != nil {
			return err
		}
		seller.Value, err = add(seller.Value, dataset.Price-n*dataset.Price/dataset.N_subset)
		if err != nil {
			return err
		}
		order.EndTime = time.Time{}
		// write buyer
		buyerJSON, err := json.Marshal(buyer)
		if err != nil {
			return err
		}
		err = ctx.GetStub().PutState(order.Buyer, buyerJSON)
		if err != nil {
			return fmt.Errorf("failed to put to world state. %v", err)
		}
		//write contract
		contractJSON, err := json.Marshal(contract)
		if err != nil {
			return err
		}
		err = ctx.GetStub().PutState("contract", contractJSON)
		if err != nil {
			return fmt.Errorf("failed to put to world state. %v", err)
		}
		// write seller
		sellerJSON, err := json.Marshal(seller)
		if err != nil {
			return err
		}
		err = ctx.GetStub().PutState(dataset.Owner, sellerJSON)
		if err != nil {
			return fmt.Errorf("failed to put to world state. %v", err)
		}
		// write order
		orderJSON, err := json.Marshal(order)
		if err != nil {
			return err
		}
		err = ctx.GetStub().PutState(orderID, orderJSON)
		if err != nil {
			return fmt.Errorf("failed to put to world state. %v", err)
		}
		return nil
	}
	return nil
}

func checkInitialized(ctx contractapi.TransactionContextInterface) (bool, error) {
	userListAsBytes, err := ctx.GetStub().GetState("UserList")
	if err != nil {
		return false, fmt.Errorf("failed to get UserList: %v", err)
	}

	if userListAsBytes == nil {
		return false, nil
	}

	return true, nil
}

/*
Add Cash System
*/
func (s *SmartContract) Mint(ctx contractapi.TransactionContextInterface, uID string, value int) error {
	/*
		Mint money to user
		Only bank can invoke this function
	*/
	userAsBytes, err := ctx.GetStub().GetState(uID)
	if err != nil {
		return fmt.Errorf("failed to read from world state. %v", err)
	}
	var user User
	err = json.Unmarshal(userAsBytes, &user)
	if err != nil {
		return err
	}
	user.Value, err = add(user.Value, value)
	if err != nil {
		return err
	}
	userJSON, err := json.Marshal(user)
	if err != nil {
		return err
	}
	err = ctx.GetStub().PutState(uID, userJSON)
	if err != nil {
		return fmt.Errorf("failed to put to world state. %v", err)
	}
	return nil
}

func (s *SmartContract) Burn(ctx contractapi.TransactionContextInterface, uID string, value int) error {
	/*
		Burn money from user
		Only bank can invoke this function
	*/
	userAsBytes, err := ctx.GetStub().GetState(uID)
	if err != nil {
		return fmt.Errorf("failed to read from world state. %v", err)
	}
	var user User
	err = json.Unmarshal(userAsBytes, &user)
	if err != nil {
		return err
	}
	// check if value is greater than user.Value
	if user.Value < value {
		return fmt.Errorf("value is greater than user.Value")
	}
	user.Value, err = sub(user.Value, value)
	if err != nil {
		return err
	}
	userJSON, err := json.Marshal(user)
	if err != nil {
		return err
	}
	err = ctx.GetStub().PutState(uID, userJSON)
	if err != nil {
		return fmt.Errorf("failed to put to world state. %v", err)
	}
	return nil
}

// add two number checking for overflow
func add(b int, q int) (int, error) {

	// Check overflow
	var sum int
	sum = q + b

	if (sum < q || sum < b) == (b >= 0 && q >= 0) {
		return 0, fmt.Errorf("Math: addition overflow occurred %d + %d", b, q)
	}

	return sum, nil
}

// sub two number checking for overflow
func sub(b int, q int) (int, error) {

	// sub two number checking
	if q <= 0 {
		return 0, fmt.Errorf("Error: the subtraction number is %d, it should be greater than 0", q)
	}
	if b < q {
		return 0, fmt.Errorf("Error: the number %d is not enough to be subtracted by %d", b, q)
	}
	var diff int
	diff = b - q

	return diff, nil
}
