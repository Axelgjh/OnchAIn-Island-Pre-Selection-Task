// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiSigWallet {
    event Deposit(address indexed sender, uint amount);
    event SubmitTransaction(uint indexed txId);
    event ConfirmTransaction(address indexed owner, uint indexed txId);
    event RevokeConfirmation(address indexed owner, uint indexed txId);
    event ExecuteTransaction(uint indexed txId);

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint public required;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }

    Transaction[] public transactions;
    mapping(uint => mapping(address => bool)) public isConfirmed;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint _txId) {
        require(_txId < transactions.length, "tx does not exist");
        _;
    }

    modifier notExecuted(uint _txId) {
        require(!transactions[_txId].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint _txId) {
        require(!isConfirmed[_txId][msg.sender], "tx already confirmed");
        _;
    }

    constructor(address[] memory _owners, uint _required) {
        require(_owners.length > 0, "owners required");
        require(_required > 0 && _required <= _owners.length, "invalid required number");

        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }

        required = _required;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submitTransaction(address _to, uint _value, bytes memory _data)
        public onlyOwner
    {
        transactions.push(Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numConfirmations: 0
        }));

        emit SubmitTransaction(transactions.length - 1);
    }

    function confirmTransaction(uint _txId)
        public onlyOwner txExists(_txId) notExecuted(_txId) notConfirmed(_txId)
    {
        Transaction storage transaction = transactions[_txId];
        transaction.numConfirmations += 1;
        isConfirmed[_txId][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _txId);
    }

    function executeTransaction(uint _txId)
        public onlyOwner txExists(_txId) notExecuted(_txId)
    {
        Transaction storage transaction = transactions[_txId];
        require(transaction.numConfirmations >= required, "not enough confirmations");

        transaction.executed = true;
        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "tx failed");

        emit ExecuteTransaction(_txId);
    }

    function revokeConfirmation(uint _txId)
        public onlyOwner txExists(_txId) notExecuted(_txId)
    {
        Transaction storage transaction = transactions[_txId];
        require(isConfirmed[_txId][msg.sender], "tx not confirmed");

        transaction.numConfirmations -= 1;
        isConfirmed[_txId][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txId);
    }

    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }

    function getTransaction(uint _txId)
        public view returns (
            address to,
            uint value,
            bytes memory data,
            bool executed,
            uint numConfirmations
        )
    {
        Transaction memory txn = transactions[_txId];
        return (txn.to, txn.value, txn.data, txn.executed, txn.numConfirmations);
    }
}
