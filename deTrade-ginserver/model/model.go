package model

/*
DatasetList stores all IDs of the dataset
Use this to search all dataset
*/
type DatasetList struct {
	Next       int      `json:"Next"`
	DLID       string   `json:"DLID"`
	DatasetIDs []string `json:"DatasetIDs"`
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
Description: description of the dataset
IPFSAddress: IPFS address of the dataset
*/
type Dataset struct {
	DatasetID   string   `json:"DatasetID"`
	Description string   `json:"Description"`
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
