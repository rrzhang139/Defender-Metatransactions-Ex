pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/metatx/ERC2771ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/metatx/MinimalForwarderUpgradeable.sol";

/**
 * @title ERC1155Tradable
 * ERC1155Tradable - ERC1155 contract that whitelists an operator address, has create and mint functionality, and supports useful standards from OpenZeppelin,
  like _exists(), name(), symbol(), and totalSupply()
 */
contract ActiveBatch is
    ERC1155Upgradeable,
    ERC2771ContextUpgradeable,
    OwnableUpgradeable
{
    using SafeMathUpgradeable for uint256;
    uint256 private _currentTokenID;
    mapping(uint256 => uint256) private tokenSupply;
    mapping(uint256 => uint256) private tokenBurnt;
    string baseMetadataURI;
    bool private mintFlag;
    address private admin;
    uint256 _storedInitialSuply;
    event BurnedSupply(uint256 id); // will emit how much is burned so we can store in DB

    function _msgSender()
        internal
        view
        virtual
        override(ERC2771ContextUpgradeable, ContextUpgradeable)
        returns (address sender)
    {
        sender = ERC2771ContextUpgradeable._msgSender();
    }

    function _msgData()
        internal
        view
        virtual
        override(ERC2771ContextUpgradeable, ContextUpgradeable)
        returns (bytes calldata)
    {
        return ERC2771ContextUpgradeable._msgData();
    }

    function initialize(
        string memory baseURI,
        address forwarder,
        address _admin
    ) public initializer {
        __Ownable_init_unchained();
        __ERC1155_init_unchained(baseURI);
        __ERC2771Context_init_unchained(forwarder);
        admin = _admin;
        _currentTokenID = 0;
    }

    function _setBaseMetadataURI(string memory _newBaseMetadataURI) internal {
        baseMetadataURI = _newBaseMetadataURI;
    }

    function uri(uint256 _tokenID)
        public
        view
        override
        returns (string memory)
    {
        string memory hexstringtokenID;
        hexstringtokenID = StringsUpgradeable.toString(_tokenID);

        return string(abi.encodePacked(baseMetadataURI, hexstringtokenID));
    }

    function totalSupply(uint256 _id) public view returns (uint256) {
        return tokenSupply[_id];
    }

    function totalBurnt(uint256 _id) public view returns (uint256) {
        return tokenBurnt[_id];
    }

    //this is to separate ownership transaction calls, our admin wallet will approve if it passes our bridge inspection
    function approveMint(uint256 _initialSupply, bytes calldata _data)
        external
    {
        require(
            admin == _msgSender(),
            "ActiveBatch#SenderIsAdmin: SENDER_IS_ADMIN"
        );
        mintFlag = true;
        _storedInitialSuply = _initialSupply;
    }

    function create(address _initialOwner, bytes calldata _data)
        external
        onlyOwner
        returns (uint256)
    {
        // require(mintFlag, "ActiveBatch#MintAllowed: MINT_ALLOWED");
        uint256 _id = _currentTokenID.add(1);
        _currentTokenID++;
        tokenSupply[_id] = _storedInitialSuply;
        _mint(_initialOwner, _id, _storedInitialSuply, _data);
        mintFlag = false;
        return _id;
    }

    function getCurrentTokenID() external view onlyOwner returns (uint256) {
        return _currentTokenID;
    }

    // mints a new batch, we would never add on to a batch
    // function mint(
    //     address to,
    //     uint256 id,
    //     uint256 value,
    //     bytes memory data
    // ) public onlyOwner {
    //     _mint(to, id, value, data);
    //     tokenSupply[id] = tokenSupply[id].add(value);
    // }

    // function mintBatch(
    //     address to,
    //     uint256[] memory ids,
    //     uint256[] memory values,
    //     bytes memory data
    // ) public onlyOwner {
    //     for (uint256 i = 0; i < ids.length; i++) {
    //         uint256 _id = ids[i];
    //         uint256 quantity = quantities[i];
    //         tokenSupply[_id] = tokenSupply[_id].add(quantity);
    //     }
    //     _mintBatch(to, ids, values, data);
    // }

    function burn(
        address owner,
        uint256 id,
        uint256 value
    ) public {
        require(
            owner == _msgSender(),
            "ActiveBatch#SenderIsOwner: SENDER_IS_OWNER"
        );
        require(
            balanceOf(_msgSender(), id) > 0,
            "ActiveBatch#userOwnersOnly: ONLY_OWNED_USERS_ALLOWED"
        );
        tokenBurnt[id] += value;
        _burn(owner, id, value);
        emit BurnedSupply(tokenBurnt[id]);
    }

    function burnBatch(
        address owner,
        uint256[] memory ids,
        uint256[] memory values
    ) public {
        require(
            owner == _msgSender(),
            "ActiveBatch#SenderIsOwner: SENDER_IS_OWNER"
        );
        for (uint256 i = 0; i < ids.length; i++) {
            uint256 _id = ids[i];
            require(
                balanceOf(owner, _id) > 0,
                "ActiveBatch#userOwnersOnlyBurn: ONLY_OWNED_USERS_ALLOWED_BURNING"
            );
            uint256 quantity = values[i];
            tokenBurnt[_id] += quantity;
            tokenSupply[_id] = tokenSupply[_id].sub(quantity);
            emit BurnedSupply(tokenBurnt[_id]);
        }
        _burnBatch(owner, ids, values);
    }

    function exists(uint256 id) public view virtual returns (bool) {
        return tokenSupply[id] > 0;
    }
}
