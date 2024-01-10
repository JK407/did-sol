// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;

contract DIDManager {
    // 定义did 结构体
    struct DID {
        string id;
        string[] document;
        address controllerAddress;
        uint256 timestamp;
        bytes signature;
        uint256 expirateTime;
    }

    // 定义did映射
    mapping(string => DID) dids;
    // 定义address到did的映射
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

    function generateDIDIdentifier(address caller, uint256 timestamp) private pure returns (string memory) {
        bytes32 hash = keccak256(abi.encodePacked(caller, timestamp));
        return toHexString(hash);
    }

    function createDID(string memory method_name, bytes memory signature) public returns (string memory) {
        require(bytes(method_name).length > 0, "Method name cannot be empty");

        string memory identifier = generateDIDIdentifier(msg.sender, block.timestamp);
        string memory id = string(abi.encodePacked("did:", method_name, ":", identifier));

        // bytes32 messageHash = keccak256(abi.encodePacked(id));
        // bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));

        // (bool recovered, address recoveredAddress) = recoverSigner(ethSignedMessageHash, signature);
        // require(recovered, "Failed to recover signer");
        // require(recoveredAddress == msg.sender, "Invalid signature");

        DID memory newDID = DID({
            id: id,
            document: new string[](0),
            controllerAddress: msg.sender,
            timestamp: block.timestamp,
            signature: signature,
            expirateTime: 0
        });

        dids[id] = newDID;
        addressToDIDs[msg.sender].push(id);

        return id;
    }

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

        return (true, ecrecover(ethSignedMessageHash, v, r, s));
    }

    function getDIDsByAddress(address addr) public view returns (string[] memory) {
        return addressToDIDs[addr];
    }

    // 添加根据ID返回DID结构体的方法
    function getDIDById(string memory id) public view returns (DID memory) {
        return dids[id];
    }
}