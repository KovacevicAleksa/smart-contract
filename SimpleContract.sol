// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Najjednostavniji pametni ugovor za e-poslovanje
contract SimpleBusiness {
    
    // Vlasnik ugovora
    address public owner;
    
    // Skladište poruka
    string public message;
    
    // Brojač transakcija
    uint public transactionCount;
    
    // Konstruktor - poziva se samo jednom prilikom kreiranja ugovora
    constructor() {
        owner = msg.sender;
        message = "Dobrodosli!";
        transactionCount = 0;
    }
    
    // Funkcija za postavljanje poruke
    function setMessage(string memory newMessage) public {
        message = newMessage;
        transactionCount++;
    }
    
    // Funkcija za čitanje poruke
    function getMessage() public view returns (string memory) {
        return message;
    }
    
    // Funkcija za povećanje brojača
    function incrementCounter() public {
        transactionCount++;
    }
}
