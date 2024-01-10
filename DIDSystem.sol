// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DIDSystem {
    // 定义did document结构体
    struct DIDDocument {
        mapping (string => string) fields; // did document的字段映射
    }
    //  定义did结构体
    struct DID {
        string id;
        address owner;
        string publicKey;
        uint createTime;
        bool isActive;
        DIDDocument document;
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
}