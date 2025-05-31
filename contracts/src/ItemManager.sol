// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVerifier2 {
    function verifyAndExecute(
        address signal,
        uint256 root,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) external;
}

contract ItemManager {
    IVerifier2 public verifier;

    constructor(address _verifierAddress) {
        verifier = IVerifier2(_verifierAddress);
    }

    struct Item {
        string itemName;
        string buyerName;
        uint256 originalPrice;
        uint256 currentPrice;
        string description;
        address[] currentOwners;
        uint256 purchaseTimestamp;
    }

    Item[] public items;

    // Add a new item to the array
    function addItem(
        string memory _itemName,
        string memory _buyerName,
        uint256 _originalPrice,
        uint256 _currentPrice,
        string memory _description,
        uint256 root,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) public {
        // Call verifyAndExecute from Verifier2
        verifier.verifyAndExecute(msg.sender, root, nullifierHash, proof);

        address[] memory initialOwners = new address[](1);
        initialOwners[0] = msg.sender;
        
        items.push(Item({
            itemName: _itemName,
            buyerName: _buyerName,
            originalPrice: _originalPrice,
            currentPrice: _currentPrice,
            description: _description,
            currentOwners: initialOwners,
            purchaseTimestamp: block.timestamp
        }));
    }

    // Buy an item
    function buyItem(string memory _itemName, address _newOwner) public {
        for (uint i = 0; i < items.length; i++) {
            if (keccak256(bytes(items[i].itemName)) == keccak256(bytes(_itemName))) {
                // Clear current owners array
                delete items[i].currentOwners;
                // Add new owner
                items[i].currentOwners.push(_newOwner);
                // Update purchase timestamp
                items[i].purchaseTimestamp = block.timestamp;
                return;
            }
        }
        revert("Item not found");
    }

    // Get item by name
    function getItem(string memory _itemName) public view returns (
        string memory itemName,
        string memory buyerName,
        uint256 originalPrice,
        uint256 currentPrice,
        string memory description,
        address[] memory currentOwners,
        uint256 purchaseTimestamp
    ) {
        for (uint i = 0; i < items.length; i++) {
            if (keccak256(bytes(items[i].itemName)) == keccak256(bytes(_itemName))) {
                return (
                    items[i].itemName,
                    items[i].buyerName,
                    items[i].originalPrice,
                    items[i].currentPrice,
                    items[i].description,
                    items[i].currentOwners,
                    items[i].purchaseTimestamp
                );
            }
        }
        revert("Item not found");
    }

    // Get number of items
    function getNumberOfItems() public view returns (uint256) {
        return items.length;
    }
}