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

    function borrow() {
        // TO-DO
    }

    function return() {
        // TO-DO
    }

    function payBalance() {
        // TO-DO
    }
}