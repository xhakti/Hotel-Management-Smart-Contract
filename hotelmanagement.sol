// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract HotelManagement{

    // #####################      GLOBAL VALIRABLE       ###########################
    address payable public Owner ;
    address public receptionist;

    address[] public soloCustomers; //To keep the records for the solo customer
    address[] public duoCustomers; //To keep the records for the duo customer 
    address[] public familyCustomers; //To keep the records for the family customer
    mapping (address => uint ) public customerRoomType;
    mapping (uint =>mapping (address => uint )) public CustomerRecords; 
    mapping (uint => uint ) public roomRent;
    
    
    struct Rooms{
        string roomType;
        uint roomTypeCode;
        uint avaliableRoom;
        uint price;
        uint rentPerHours;
    }

    Rooms public soloRooms = Rooms("Solo", 1, 15, 1 ether, 100 wei);
    Rooms public duoRooms = Rooms("Duo", 2, 10, 2 ether, 200 wei);
    Rooms public familyRooms = Rooms("Family", 3, 5, 3 ether, 300 wei);

    constructor (address _setReceptionist) {
        Owner = payable(msg.sender);
        receptionist = _setReceptionist;
        roomRent[1] = 100;
        roomRent[2] = 200;
        roomRent[3] = 300;
    }


    // #####################      MODIFIERS       ###########################
    modifier onlyOwner() {
        require(msg.sender == Owner, " Only owner can have the acess to this function");
        _;
    }

    modifier onlyCustomer(){
        require(customerRoomType[msg.sender] == 1 || customerRoomType[msg.sender] == 2 || customerRoomType[msg.sender] == 3  , " Only a customer can access this function");
        _;
    }

    modifier onlyReceptionist(){
        require(msg.sender == receptionist); 
        _;
    }

    // #####################      FUNCTIONS       ###########################
    function avaliableRooms() public view returns (uint SoloRooms, uint DuoRooms , uint FamilyRooms){
        return (soloRooms.avaliableRoom,duoRooms.avaliableRoom,  familyRooms.avaliableRoom);
    }
    

    function checkIn(uint _roomTypeCode) public payable {
        if(_roomTypeCode == 1)
        {
            require (soloRooms.avaliableRoom > 0, "No Rooms avaliable for this Type, Please Check Other Type of rooms");
            require (msg.value == soloRooms.price, "Please Enter a Valid Amout, Solo Room const 1 Ether");
            customerRoomType[msg.sender] = _roomTypeCode;
            CustomerRecords[_roomTypeCode][msg.sender] = block.timestamp; 
            soloCustomers.push(msg.sender);
            soloRooms.avaliableRoom --;
            
        }
        else if(_roomTypeCode == 2)
        {
            require (duoRooms.avaliableRoom > 0, "No Rooms avaliable for this Type, Please Check Other Type of rooms");
            require (msg.value == duoRooms.price, "Please Enter a Valid Amout, Duo Room const 2 Ether");
            customerRoomType[msg.sender] = _roomTypeCode;
            CustomerRecords[_roomTypeCode][msg.sender] = block.timestamp; 
            duoCustomers.push(msg.sender);
            duoRooms.avaliableRoom --;
            
        }
        else if(_roomTypeCode == 3)
        {
            require (familyRooms.avaliableRoom > 0, "No Rooms avaliable for this Type, Please Check Other Type of rooms");
            require (msg.value == familyRooms.price, "Please Enter a Valid Amout, Family Room const 3 Ether");
            customerRoomType[msg.sender] = _roomTypeCode;
            CustomerRecords[_roomTypeCode][msg.sender] = block.timestamp; 
            familyCustomers.push(msg.sender);
            familyRooms.avaliableRoom --;
            
        }
    }
    

    // View Rent for the Customer
    function viewRent() public onlyCustomer view returns(uint _RENT)
    {
        //                                          this will evaluate to           1/2/3       
        uint totalHoursCheckedin = block.timestamp - CustomerRecords[customerRoomType[msg.sender]][msg.sender]; // block.timestamp - [typeOfRoom][address] => the time they checkedIn ;
        uint payableHours = totalHoursCheckedin / 3600 ;
        uint totalRent = roomRent[customerRoomType[msg.sender]] * payableHours;
        return totalRent;
        
    }


    function checkOut() public payable onlyCustomer 
    {
        if (customerRoomType[msg.sender] == 1) 
        {
        uint rent = viewRent();
        require(msg.value == rent , "Please check your rent and then pay the amount eligible"); 
        soloRooms.avaliableRoom ++;
        }
        else if (customerRoomType[msg.sender] == 2)
        {
            uint rent = viewRent();
            require(msg.value == rent , "Please check your rent and then pay the amount eligible"); 
            duoRooms.avaliableRoom ++;
        }
        else if (customerRoomType[msg.sender] == 3)
        {
            uint rent = viewRent();
            require(msg.value == rent , "Please check your rent and then pay the amount eligible"); 
            familyRooms.avaliableRoom ++;
        }

    }
    

    // View Rent of Customers for the receptionist
     function viewRent(address _adddressOfCustomer) public  view onlyReceptionist returns(uint _rentOfTheCustomer)
    {
        //                                          this will evaluate to            1/2/3       
        uint totalHoursCheckedin = block.timestamp - CustomerRecords[customerRoomType[_adddressOfCustomer]][_adddressOfCustomer]; // block.timestamp - [typeOfRoom][address] => the time they checkedIn ;
        uint payableHours = totalHoursCheckedin / 3600 ;
        uint totalRent = roomRent[customerRoomType[_adddressOfCustomer]] * payableHours;
        return totalRent;
    
    }



    //FUNCTION view revinew
    function viewRevenue() public view onlyOwner returns(uint _revenue)
    {
        return address(this).balance;

    }

    // FINCTION withdraw revenue
    function withdrawRevenue() public payable onlyOwner
    {
        uint totalRevenue = address(this).balance;
        Owner.transfer(totalRevenue);
    }
    
    // Change Recepionists 
    function changeReceptionist(address _newReceptionist) public onlyOwner
    {
        receptionist = _newReceptionist;
    }
     
}
