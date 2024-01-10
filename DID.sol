// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

contract DIDManager {
    // 定义did 结构体
    struct DID {
        string id;
        Document document;
        address controller_address;
        uint256 timestamp;
        bytes signature;
        uint256 expirate_time;
    }

    struct Document {
        string controller;
        string id;
    }

    mapping(string => DID) dids;
    mapping(address => string[]) addressToDIDs;



    function toHexString(bytes32 value) private pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(64);
        for (uint256 i = 0; i < 32; i++) {
            str[2 * i] = alphabet[uint256(uint8(value[i] >> 4))];
            str[2 * i + 1] = alphabet[uint256(uint8(value[i] & 0x0f))];
        }
        return string(str);
    }

    // 生成id方法
    function generateDIDIdentifier(address caller, uint256 timestamp) private pure returns (string memory) {
        bytes32 hash = keccak256(abi.encodePacked(caller, timestamp));
        return toHexString(hash);
    }

    // 创建did
    function createDID(string memory method_name) public returns (string memory) {
        require(bytes(method_name).length > 0, "Method name cannot be empty");

        string memory identifier = generateDIDIdentifier(msg.sender, block.timestamp);
        string memory id = string(abi.encodePacked("did:", method_name, ":", identifier));
        // 使用id加#document拼接成一个string
        string memory documentId = string(abi.encodePacked(id, "#document"));
        Document memory newDocument = Document({
            controller: id,
            id: documentId
        });

        DID memory newDID = DID({
            id: id,
            document: newDocument,
            controller_address: msg.sender,
            timestamp: block.timestamp,
            signature: new bytes(0), // 初始化为空的签名信息
            expirate_time: 0
        });

        dids[id] = newDID;
        addressToDIDs[msg.sender].push(id);

        return id;
    }

    // 存入签名信息
    function setSignature(string memory id, bytes memory signature) public {
        DID storage did = dids[id];
        require(bytes(did.id).length > 0, "DID does not exist");
        require(did.controller_address == msg.sender, "Not authorized to set signature");
        did.signature = signature;
    }


    // 解析签名
    function recoverSigner(bytes32 ethSignedMessageHash, bytes memory signature) public pure returns (bool, address) {
        if (signature.length != 65) {
            return (false, address(0));
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return (false, address(0));
        }

        address recoveredAddress = ecrecover(ethSignedMessageHash, v, r, s);
        return (true, recoveredAddress);
    }

    function getDIDsByAddress(address addr) public view returns (string[] memory) {
        return addressToDIDs[addr];
    }

    // 添加根据ID返回DID结构体的方法
    function getDIDById(string memory id) public view returns (DID memory) {
        return dids[id];
    }



}