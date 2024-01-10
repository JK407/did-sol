// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract DIDTest {
    // 定义DIDStruct 结构体
    struct DIDStruct {
        string did; // did
        Document document; // didDocument
        address holder_address; // 持有者地址
        uint256 timestamp; // 创建时间
        bytes signature; // 签名信息
    }
    // 定义didDocument结构体
    struct Document {
        string controller; // 控制者
        string id; // didDocument did
        PersonalInfo personalInfo; // 个人信息
        string publicKey; // 公钥
        Authentication []authentication; // 认证
    }
    // 定义认证结构体
    struct Authentication {
        string id; // 认证did
        string authentication_type; // 类型
        string publicKey; // 公钥

    }
    // 定义个人信息结构体
    struct PersonalInfo {
        string name; // 姓名
        int age; // 年龄
        string sex; // 性别
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

    // 生成id方法
    function generateDIDIdentifier(address caller, uint256 timestamp) private pure returns (string memory) {
        bytes32 hash = keccak256(abi.encodePacked(caller, timestamp));
        return toHexString(hash);
    }

    // 创建did
    function createDID(string memory role_name,string memory name,string memory sex, int age) public view  returns (DIDStruct memory) {
        require(bytes(role_name).length > 0, "Role name cannot be empty");

        string memory identifier = generateDIDIdentifier(msg.sender, block.timestamp);
        string memory id = string(abi.encodePacked("did:", role_name, ":", identifier));
        // 使用id加#document拼接成一个string
        string memory documentId = string(abi.encodePacked(id, "#document"));
        // 定义个人信息
        PersonalInfo memory newPersonalInfo = PersonalInfo({
            name: name,
            age : age,
            sex : sex
        });
        Document memory newDocument = Document({
            controller: id,
            id: documentId,
            personalInfo: newPersonalInfo,
            publicKey : "",
            authentication : new Authentication[](0)
        });

        DIDStruct memory newDID = DIDStruct({
            did: id,
            document: newDocument,
            holder_address: msg.sender,
            timestamp: block.timestamp,
            signature: new bytes(0) // 初始化为空的签名信息
        });

        return newDID;
    }

}
