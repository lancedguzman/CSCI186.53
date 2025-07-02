// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract RizalLibary {
    address internal librarian;

    enum Status { Available, Borrowed }
    Status constant defaultStatus = Status.Available;

    enum HoldOrder { Yes, No }
    HoldOrder constant defaultHoldOrder = HoldOrder.No;

    struct Student {
        uint idnumber;
        uint balance;
        HoldOrder holdorder;
    }

    struct Book {
        uint callnumber;
        Status status;
    }

    mapping(address => Student) public students;
    mapping(uint => Book) public books;
    mapping(address => uint) public borrowedBook;
    mapping(address => uint) public bookTimeStamp;


    modifier isLibrarian() {
        require(msg.sender == librarian, "You are not the Librarian!");
        _;
    }

    modifier isStudent() {
        require(msg.sender != librarian, "Librarians cannot perform this transaction!");
        _;
    }

    event StudentEnrolled(address indexed studentAddress, uint idnumber);

    constructor() {
        librarian = msg.sender;
    }
    
        function addStudent() {
        // TO-DO
    }

        function borrow(uint _callnumber) public isStudent{
            require(students[msg.sender].idnumber != 0, "Student not Enrolled");
            require(students[msg.sender].holdorder == HoldOrder.No, "You Have a HoldOrder");
            require(borrowedBook[msg.sender] == 0, "Already Borrowed A Book!");
            require(books[_callnumber].status == Status.Available, "Book is not Available");
            books[_callnumber].status == Status.Borrowed;
            borrowedBook[msg.sender] = _callnumber;
            bookTimeStamp[msg.sender] = block.timestamp;
    }

        function return() {
        // TO-DO for the hold order you can use th block.timestamp in my function borrow to check the time just search how it works if not familiar. Then update the book that was borrowed to Available just copy
        // line 54 of my code then update line 55 and 56 si that the student will have no more borrowed books
        // and the timestamp of the borrowed book is removed since the book has been returned
    
    }

    function payBalance() {
        // TO-DO
    }

}