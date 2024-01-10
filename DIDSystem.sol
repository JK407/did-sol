// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DIDSystem {
    // 定义DIDDocument结构体
    struct DIDDocument {
        string id; // didDocument did
        string controller; // 控制者
        string publicKey; // 公钥
    }

    //  定义did结构体
    struct DID {
        string id;
        address owner;
        string signature;
        uint createTime;
        bool isActive;
        string documentURI; // 指向DID文档的URI
        Credential[] credentials;
    }
    //  定义签证结构体
    struct Credential {
        string controller;
        address issuer;
        address holder;
        string data;
        uint createTime;
        uint expireTime;
        bool isActive;
        string signature;
    }

    //  定义did映射
    mapping(string => DID) private dids;
    // 映射DID到其文档
    mapping(string => DIDDocument) private didDocument;
    // 定义DID到其所有者地址的映射
    mapping(string => address) private didToOwner;

    // 定义地址到DID数组的映射
    mapping(address => string[]) private ownerToDIDs;
    // 定义用户和DID名称到DID标识符的映射
    mapping(address => mapping(string => bool)) private ownerToDidNameExists;
    // DID创建事件
    event DIDCreated(string indexed didName, address indexed owner, string didId);

    //  创建did
    function createDID(string memory didName) public {
        require(bytes(didName).length > 0, "DID name is empty");
        // 确保用户还没有为这个didName创建过DID
        require(!ownerToDidNameExists[msg.sender][didName], "DID name already used for this owner");
        string memory identifier = generateDIDIdentifier(msg.sender, block.timestamp);
        string memory id = string(abi.encodePacked("did:", didName, ":", identifier));
        string memory documentId = string(abi.encodePacked(id, "#document"));
        // 防止重复的DID
        require(dids[id].createTime == 0, "DID already exists");

        DID storage newDid = dids[id]; // 使用存储引用
        newDid.id = id;
        newDid.owner = msg.sender;
        newDid.signature = '';
        newDid.createTime = block.timestamp;
        newDid.isActive = true;
        //  newDid.credentials = new Credential[](0); // 初始化凭证数组
        DIDDocument storage newDidDocument = didDocument[id];
        newDidDocument.id = documentId;
        newDidDocument.controller = id;
        // 存储地址到DID的映射
        ownerToDIDs[msg.sender].push(id);
        // 更新DID到所有者的映射
        didToOwner[id] = msg.sender;
        // 在映射中标记该用户已经使用了这个didName
        ownerToDidNameExists[msg.sender][didName] = true;
        // 触发事件
        emit DIDCreated(didName, msg.sender, id);

    }

    // 生成id方法
    function generateDIDIdentifier(address caller, uint256 timestamp) private pure returns (string memory) {
        bytes32 hash = keccak256(abi.encodePacked(caller, timestamp));
        return toHexString(hash);
    }

    // toHexString方法
    function toHexString(bytes32 value) private pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(64);
        for (uint256 i = 0; i < 32; i++) {
            str[2 * i] = alphabet[uint256(uint8(value[i] >> 4))];
            str[2 * i + 1] = alphabet[uint256(uint8(value[i] & 0x0f))];
        }
        return string(str);
    }

    // 获取用户的所有DID
    function getDIDsByOwner(address owner) public view returns (string[] memory) {
        return ownerToDIDs[owner];
    }

    // 根据id获取did
    function getDIDById(string memory didId) public view returns (
        string memory id,
        address owner,
        string memory signature,
        uint createTime,
        bool isActive,
        Credential[] memory credentials
    ) {
        require(dids[didId].owner != address(0), "DID does not exist");

        DID storage did = dids[didId];
        return (
            did.id,
            did.owner,
            did.signature,
            did.createTime,
            did.isActive,
            did.credentials
        );
    }
    // 函数，用于获取DID文档
    function getDIDDocument(string memory did) public view returns (string memory id, string memory controller) {
        require(msg.sender == didToOwner[did], "Caller is not authorized to view the DID document");
        return (
            didDocument[did].id,
            didDocument[did].controller
        );
    }

}