// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title CarAgency
 * @dev Pametni ugovor za auto agenciju - kupovina i prodaja automobila
 */
contract CarAgency {
    
    // Vlasnik ugovora (auto agencija)
    address public owner;
    
    // Struktura za automobil
    struct Car {
        uint id;
        string brand;
        string model;
        uint year;
        uint price; // Cena u wei
        address currentOwner;
        bool isAvailable;
    }
    
    // Mapiranje ID-ja automobila na podatke
    mapping(uint => Car) public cars;
    
    // Brojač automobila
    uint public carCount;
    
    // Ukupna zarada agencije
    uint public totalEarnings;
    
    // Eventi
    event CarAdded(uint carId, string brand, string model, uint price);
    event CarSold(uint carId, address buyer, uint price);
    event CarPriceUpdated(uint carId, uint newPrice);
    
    // Modifikator - samo vlasnik može pozivati funkciju
    modifier onlyOwner() {
        require(msg.sender == owner, "Samo vlasnik moze izvrsiti ovu akciju");
        _;
    }
    
    // Konstruktor
    constructor() {
        owner = msg.sender;
        carCount = 0;
        totalEarnings = 0;
    }
    
    /**
     * @dev Dodavanje novog automobila u ponudu
     */
    function addCar(
        string memory _brand,
        string memory _model,
        uint _year,
        uint _price
    ) public onlyOwner {
        carCount++;
        
        cars[carCount] = Car({
            id: carCount,
            brand: _brand,
            model: _model,
            year: _year,
            price: _price,
            currentOwner: owner,
            isAvailable: true
        });
        
        emit CarAdded(carCount, _brand, _model, _price);
    }
    
    /**
     * @dev Kupovina automobila
     */
    function buyCar(uint _carId) public payable {
        require(_carId > 0 && _carId <= carCount, "Automobil ne postoji");
        require(cars[_carId].isAvailable, "Automobil nije dostupan");
        require(msg.value >= cars[_carId].price, "Nedovoljna kolicina sredstava");
        
        // Prenos vlasništva
        cars[_carId].currentOwner = msg.sender;
        cars[_carId].isAvailable = false;
        
        // Dodavanje zarade
        totalEarnings += msg.value;
        
        // Vraćanje viška novca ako je poslato više
        if (msg.value > cars[_carId].price) {
            payable(msg.sender).transfer(msg.value - cars[_carId].price);
        }
        
        emit CarSold(_carId, msg.sender, cars[_carId].price);
    }
    
    /**
     * @dev Ažuriranje cene automobila
     */
    function updateCarPrice(uint _carId, uint _newPrice) public onlyOwner {
        require(_carId > 0 && _carId <= carCount, "Automobil ne postoji");
        require(cars[_carId].isAvailable, "Automobil nije dostupan");
        
        cars[_carId].price = _newPrice;
        
        emit CarPriceUpdated(_carId, _newPrice);
    }
    
    /**
     * @dev Dobijanje informacija o automobilu
     */
    function getCar(uint _carId) public view returns (
        string memory brand,
        string memory model,
        uint year,
        uint price,
        address currentOwner,
        bool isAvailable
    ) {
        require(_carId > 0 && _carId <= carCount, "Automobil ne postoji");
        
        Car memory car = cars[_carId];
        return (
            car.brand,
            car.model,
            car.year,
            car.price,
            car.currentOwner,
            car.isAvailable
        );
    }
    
    /**
     * @dev Vraćanje svih dostupnih automobila
     */
    function getAvailableCarsCount() public view returns (uint) {
        uint count = 0;
        for (uint i = 1; i <= carCount; i++) {
            if (cars[i].isAvailable) {
                count++;
            }
        }
        return count;
    }
    
    /**
     * @dev Povlačenje sredstava (samo vlasnik)
     */
    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        require(balance > 0, "Nema sredstava za povlacenje");
        
        payable(owner).transfer(balance);
    }
    
    /**
     * @dev Provera stanja ugovora
     */
    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}
