// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DiamondLifecycle {

    // address public miningCompany; 
    // address public cuttingCompany;     
    // address public qualityControlLab; 
    // address public jewelryMaker;     
    // address public customer;           

    // diamond lifecycle status
    enum LifecycleState {
        NotExist,
        Mined, 
        CutPolished, 
        QualityChecked, 
        OwnedByMaker, 
        EmbeddedInJewelry, 
        Purchased,
        ForSell    
    }
    // enum verifyStatus{
    //     successful,
    //     failed,
    //     notVerify
    // }


    // define diamond structure
    struct Diamond {
        uint256 id;                        // Diamond Unique ID
        uint256 price;                     //Price of diamond
        string grade;                      //Quality grade
        bytes32 uniqueLaserID;            // Laser engraving ID
        bytes digitalCertificate;       // digital certificate of diamond
        LifecycleState state;            // Current lifecycle status
        address currentOwner;            // Current owner
        // verifyStatus verify_status ;
    }
    //trace the path of diamond
    struct DiamondTrace {
        uint256 id;                        // Diamond Unique ID
        address mining_company;             //which the mining company mine the diamond
        uint256 mining_time;                 //show the time when mining company mine the diamond
        address cutting_company;             //which the cutting company cut and polish diamond
        uint256 cutting_time;                 //show the time when cutting company cut the diamond
        address quality_control_lab;       //which the quality control lab check whether is good quality
        uint256 grading_time;                 //show the time when lab grade the diamond
        uint256 engraving_time;                 //show the time when lab engraving the diamond
        address jewelry_maker;            //which the jewelrymaker mine the diamond
        uint256 designingAndInlaying_time;  //show the time when jewelrymaker design and inlay the diamond
        uint256 issueCertificate_time;    //record the time when jewelrymaker issue the certificate for diamond
        uint256 owner_time;              //record the time when current owner own the diamond
    }

    // diamond mapping
    mapping(uint256 => Diamond) public diamonds;
    mapping(uint256 => DiamondTrace) public diamondTraceMapping;
    mapping(address => string[]) public certificates;
    // address and role mapping
    mapping(address => string) private users;
    // array of diamonds
    uint256[] public diamondIds;

    // all events
    event UserRegistered(address indexed userAddress, string role);//register users
    event DiamondMined(uint256 id, address indexed miner);// diamond mining has occurred
    event DiamondCutPolished(uint256 id, address indexed cutter);// cut and polish diamond has occurred
    event QualityChecked(uint256 id,string grade, bytes32 laserID, address indexed lab);// check quality and laser engrave has occurred
    event OwnedByJewelryMaker(uint256 id, address indexed maker);// transfer to jewelryMaker has occurred
    event EmbeddedInJewelry(uint256 id, address indexed maker);// embed diamond into jewelry has occurred
    event Purchased(uint256 id, address indexed buyer);// consumer purchase of diamonds has occurred
    event CertificateIssued(uint256 id, bytes certificate, address indexed issuer);// issue Certificate has occurred
    event CertificateTransferred(uint256 id, address indexed newOwner);// Transfer of digital certificate has occurred
    event Diamondverified(string uniqueLaserID,bytes signature,address indexed expected_signer,address indexed recover_signer);
    event Diamondsell(uint256 diamondId);

    constructor() {
        
    }

    // function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
    //     bytes memory bytesArray = new bytes(32);
    //     for (uint256 i = 0; i < 32; i++) {
    //         bytesArray[i] = _bytes32[i];
    //     }
    //     return string(bytesArray);
    // }

    function registerUser(string memory role) public {
        require(bytes(users[msg.sender]).length == 0, "User already registered");
        users[msg.sender] = role;
        emit UserRegistered(msg.sender, role);
    }

    // judge whether the user exists
    function userExists(address userAddress) public view returns (bool) {
        return bytes(users[userAddress]).length > 0;
    }

    function getUser(address userAddress) public view returns (address, string memory role) {
        require(bytes(users[userAddress]).length > 0, "User not found");
        return (userAddress, users[userAddress]);
    }
    function getDiamondTraceById(uint256 diamondId) public view returns (DiamondTrace memory) {
        // require(bytes(diamondTraceMapping[diamondId]).length > 0, "Diamond information not found");
         return diamondTraceMapping[diamondId];
    }

    function getAllDiamonds() public view returns (Diamond[] memory) {
        Diamond[] memory allDiamonds = new Diamond[](diamondIds.length);
        for (uint256 i = 0; i < diamondIds.length; i++) {
            allDiamonds[i] = diamonds[diamondIds[i]];
        }
        return allDiamonds;
    }

     function getDiamondById(uint256 diamondId) public view returns (Diamond memory) {
        require(bytes(users[msg.sender]).length > 0, "User not found");
         return diamonds[diamondId];
    }



    // mine diamond
    function mineDiamond(uint256 diamondId) public {
        require(keccak256(abi.encodePacked("miningCompany")) == keccak256(abi.encodePacked(users[msg.sender])), "Only the mining company can mine diamonds.");
        require(diamonds[diamondId].state == LifecycleState.NotExist, "Diamond already exists.");

        diamonds[diamondId] = Diamond({
            id: diamondId,
            price: 0,
            grade: "",
            uniqueLaserID:"",
            digitalCertificate: "",
            state: LifecycleState.Mined,
            currentOwner: msg.sender
            // verify_status:verifyStatus.notVerify
        });

        diamondTraceMapping[diamondId]=DiamondTrace({
        id:diamondId, 
        mining_company :msg.sender,               
        mining_time :block.timestamp,              
        cutting_company :address(0),
        cutting_time: 0,                        
        quality_control_lab : address(0),            
        grading_time : 0,                                            
        engraving_time : 0,                
        jewelry_maker: address(0),           
        designingAndInlaying_time: 0, 
        issueCertificate_time: 0,
        owner_time:0
        });

        diamondIds.push(diamondId);
        emit DiamondMined(diamondId, msg.sender);
    }

    // cut and polish diamond
    function cutAndPolishDiamond(uint256 diamondId) public {
        require(keccak256(abi.encodePacked("cuttingCompany")) == keccak256(abi.encodePacked(users[msg.sender])), "Only the cutting company can cut and polish diamonds.");
        require(diamonds[diamondId].state == LifecycleState.Mined, "Diamond must be mined first.");
        //change state
        diamonds[diamondId].state = LifecycleState.CutPolished;
        //record
        diamondTraceMapping[diamondId].cutting_company=msg.sender;
        diamondTraceMapping[diamondId].cutting_time=block.timestamp;
        emit DiamondCutPolished(diamondId, msg.sender);
    }

    // check quality and laser engrave
    function qualityCheckAndLaserEngrave(uint256 diamondId,string memory grade) public {
        require(keccak256(abi.encodePacked("qualityControlLab")) == keccak256(abi.encodePacked(users[msg.sender])), "Only the quality control lab can perform this action.");
        require(diamonds[diamondId].state == LifecycleState.CutPolished, "Diamond must be cut and polished first.");
        // grading quality
        diamonds[diamondId].grade =grade ;
        diamondTraceMapping[diamondId].quality_control_lab=msg.sender;
        diamondTraceMapping[diamondId].grading_time=block.timestamp;
        //laser engrave
        bytes32 laserID=keccak256(abi.encodePacked(msg.sender,grade,diamondId,block.timestamp));
        diamonds[diamondId].uniqueLaserID =laserID;
        diamonds[diamondId].state = LifecycleState.QualityChecked;
        diamondTraceMapping[diamondId].engraving_time=block.timestamp;
        emit QualityChecked(diamondId, grade,laserID, msg.sender);
    }
        // transfer to jewelryMaker
    function transferToJewelryMaker(uint256 diamondId,address jewelryMakerId) public {
        require(keccak256(abi.encodePacked("miningCompany")) == keccak256(abi.encodePacked(users[msg.sender])), "Only the mining Company can transfer to the jewelry maker.");
        require(keccak256(abi.encodePacked("jewelryMaker")) == keccak256(abi.encodePacked(users[jewelryMakerId])), "You are only allowed to transfer to the jewelry maker.");
        require(diamonds[diamondId].state == LifecycleState.QualityChecked, "Diamond must be quality checked first.");
        diamonds[diamondId].currentOwner = jewelryMakerId;
        diamonds[diamondId].state = LifecycleState.OwnedByMaker;
        diamondTraceMapping[diamondId].jewelry_maker=jewelryMakerId;
        emit OwnedByJewelryMaker(diamondId, msg.sender);
    }


    // embed diamond into jewelry
    function embedInJewelry(uint256 diamondId) public {
        require(keccak256(abi.encodePacked("jewelryMaker")) == keccak256(abi.encodePacked(users[msg.sender])), "Only the jewelry maker can embed diamonds in jewelry.");
        require(diamonds[diamondId].state == LifecycleState.OwnedByMaker, "Diamond must be owned by jewelry maker.");
        diamonds[diamondId].state = LifecycleState.EmbeddedInJewelry;
        diamondTraceMapping[diamondId].designingAndInlaying_time=block.timestamp;
        emit EmbeddedInJewelry(diamondId, msg.sender);
    }

   // issue Certificate
    function issueCertificate(uint256 diamondId,bytes memory certificate,uint256 price) public {
        require(keccak256(abi.encodePacked("jewelryMaker")) == keccak256(abi.encodePacked(users[msg.sender])), "Only the jewelry maker can issue certificates.");
        require(diamonds[diamondId].state == LifecycleState.EmbeddedInJewelry, "Diamond must be embedded in jewelry.");
        // update certificate
        diamonds[diamondId].price = price;
        diamonds[diamondId].digitalCertificate = certificate;
        diamondTraceMapping[diamondId].issueCertificate_time=block.timestamp;
        // emit event
        emit CertificateIssued(diamondId, certificate, msg.sender);
    }


    // transfer Certificate
    function transferCertificate(uint256 diamondId, address newOwner) public {
        // require(keccak256(abi.encodePacked("jewelryMaker")) == keccak256(abi.encodePacked(users[msg.sender])), "Only the jewelry maker can issue certificates.");
        require(diamonds[diamondId].state == LifecycleState.Purchased, "Diamond must be purchased.");
        // update ownership
        diamonds[diamondId].currentOwner = newOwner;
        emit CertificateTransferred(diamondId, newOwner);
    }


    // purchase
    function purchaseDiamond(uint256 diamondId) public payable{
        require(msg.sender != address(0), "Invalid buyer address.");
        require(diamonds[diamondId].state==LifecycleState.EmbeddedInJewelry||diamonds[diamondId].state==LifecycleState.ForSell,"The ownership mush be owned by jewelry maker or for sold by custermer");
        require(msg.value == diamonds[diamondId].price, "Insufficient funds sent for purchase");
        payable(diamondTraceMapping[diamondId].jewelry_maker).transfer(msg.value);
        diamonds[diamondId].state = LifecycleState.Purchased;

        transferCertificate(diamondId, msg.sender);
        diamondTraceMapping[diamondId].owner_time=block.timestamp;
        emit Purchased(diamondId, msg.sender);
    }

    function sellDiamond(uint256 diamondId) public {
        require(diamonds[diamondId].state==LifecycleState.Purchased,"The diamond must be purchased first");
        require(msg.sender == diamonds[diamondId].currentOwner,"only the owner of diamond could sell");
        diamonds[diamondId].state = LifecycleState.ForSell;
        emit Diamondsell(diamondId);
    }

    //verify certificate
    function verifyDiamond(string memory uniqueLaserID,bytes memory signature,address expected_signer) public returns (bool)  {
        address recover_signer = recoverSigner(uniqueLaserID, signature);
        bool isValid = (recover_signer != address(0));
        require(isValid,"recover failed");
        // emit SignatureVerified(signer, isValid);
        emit Diamondverified(uniqueLaserID,signature,expected_signer,recover_signer);
        return(expected_signer==recover_signer);
    }

     function recoverSigner(string memory message, bytes memory signature) internal pure returns (address) {
        bytes32 messageHash = keccak256(abi.encodePacked(message));
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(signature);
        return ecrecover(messageHash, v, r, s);
    }

    function splitSignature(bytes memory signature) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(signature.length == 65, "Invalid signature length");
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
        // Adjust v value
        if (v < 27) {
            v += 27;
        }
    }

}
